# Pretty hacky script to get positions from HGVS
# Versions aren't listed for ENST so several positions given. From a quick look,
# seems like the most recent version is returned first so picked this
# Takes a long time to run, could do with not essentially looping through API per row
# but didn't didn't work out a vectorised method.
# Will throw warning messages on running as not all HGVS is useable for ensembl API

# Usage:
# Rscript cosmic_to_bedpe.R $input.tsv $output.tsv

## if biomaRt not installed:
# source("http://bioconductor.org/biocLite.R")
# biocLite("biomaRt")

library(stringr)
library(biomaRt)
library(httr)
library(jsonlite)
library(xml2)
library(tidyverse)

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)

input_file <- args[1]
output_file <- args[2]

# Set up biomart transcripts to map refseq to ensembl id
ensembl = useEnsembl(biomart="ensembl", dataset="hsapiens_gene_ensembl", GRCh=37)
transcripts <- getBM(attributes = c('refseq_mrna', 'ensembl_transcript_id'),
                     mart=ensembl) %>%
  filter(refseq_mrna != '')

get_position <- function(translocation_name){
  # Splits up translocation name and gets positions from HGVS using ensembl rest API
  # returns data frame of positions for transcript1 and 2
  # if either of the positions missing, returns NA for all fields

  split_list = str_split(translocation_name, pattern="[{}]")[[1]]
  # Ensembl or refseq
  trans1 = split_list[2]
  # start and end
  c_dna1 = str_split(split_list[3], pattern=":r.|_")[[1]][2:3]
  trans2 = split_list[4]
  c_dna2 = str_split(split_list[5], pattern=":r.|_")[[1]][2:3]
  if(!(is.na(trans1) | is.na(trans2))){
    # if refseq, convert to ensembl transcript id
    if(str_detect(trans1, "NM_*")){
      # remove version as not contained in biomart
      refseq <- str_split(trans1, pattern="\\.")[1]
      trans1 <- filter(transcripts, refseq_mrna == refseq)[1,1]
    }
    if(str_detect(trans2, "NM_*")){
      # remove version as not contained in biomart
      refseq <- str_split(trans2, pattern="\\.")[1]
      trans2 <- filter(transcripts, refseq_mrna == refseq)[1,1]
    }
  }
  # Use ensembl API to convert HGVS information to genomic position
  server <- "http://grch37.rest.ensembl.org"
  query1 <- paste("/map/cdna/", trans1, "/",c_dna1[1], "..", c_dna1[2],"?",
                  sep="")
  r1 <- GET(paste(server, query1, sep = ""), content_type("application/json"))

  try({
    stop_for_status(r1)
    out1 <- fromJSON(toJSON(content(r1)))$mappings %>%
      mutate(strand = if_else(strand == 1,
                              '+', '-', '.')) %>%
      rename(chrom1 = seq_region_name,
             start1 = start,
             end1 = end,
             strand1 = strand) %>%
      dplyr::select(matches("*1")) %>%
      slice(1) %>%
      mutate(trans1 = trans1)
  })

  query2 <- paste("/map/cdna/", trans2, "/",c_dna2[1], "..", c_dna2[2],"?",
                  sep="")
  r2 <- GET(paste(server, query2, sep = ""), content_type("application/json"))

  try({
    stop_for_status(r2)
    out2 <- fromJSON(toJSON(content(r2)))$mappings %>%
      mutate(strand = if_else(strand == 1,
                              '+', '-', '.')) %>%
      rename(chrom2 = seq_region_name,
             start2 = start,
             end2 = end,
             strand2 = strand) %>%
      dplyr::select(matches("*2")) %>%
      slice(1) %>%
      mutate(trans2 = trans2)

  })

  # return empty data frame as default
  output <- data.frame(rbind(c(start1=NA, end1=NA, strand1=NA, chrom1=NA, trans1=NA,
                               start2=NA, end2=NA, strand2=NA, chrom2=NA, trans2=NA)))
  # if complete dataset for transcript1 and 2, returns all information, otherwise NA for all fields
  try({
    output <- out1 %>%
      bind_cols(out2)
  })

  return(output)

}


# import cosmic export and get positions
cosmic_table <- read_tsv(input_file) %>%
  filter(!is.na(`Translocation Name`)) %>%
  rowwise() %>%
  # Parse each HGVS pair to get position
  mutate(temp = list(get_position(`Translocation Name`))) %>%
  mutate(start1 = temp$start1 ) %>%
  mutate(end1 = temp$end1 ) %>%
  mutate(chrom1 = temp$chrom1) %>%
  mutate(strand1 = temp$strand1) %>%
  mutate(trans1 = temp$trans1)
  mutate(start2 = temp$start2 ) %>%
  mutate(end2 = temp$end2 ) %>%
  mutate(chrom2 = temp$chrom2) %>%
  mutate(strand2 = temp$strand2) %>%
  mutate(trans2 = temp$trans2) %>%
  ungroup() %>%
  # removes any columns without full genomic position
  filter(!is.na(strand1))


bedpe_columns <- c("chrom1", "start1", "end1",
                   "chrom2", "start2", "end2",
                   "name", "score", "strand1", "strand2",
                   "trans1", "trans2")

cosmic_bedpe <- cosmic_table %>%
  rename(name = `Translocation Name`) %>%
  mutate(score = 0) %>%
  # order columns to have BEDPE 10 defined columns first
  dplyr::select(bedpe_columns, which(!colnames(cosmic_table) %in% bedpe_columns)) %>%
  dplyr::select(-temp) %>%
  # unlist (caused by temp) to allow for export
  mutate_all(.funs=unlist)

write_tsv(cosmic_bedpe, output_file)
