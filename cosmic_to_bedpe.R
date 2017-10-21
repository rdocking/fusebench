## if biomaRt not installed:
# source("http://bioconductor.org/biocLite.R")
# biocLite("biomaRt")

library(tidyverse)
library(stringr)
library(biomaRt)


library(httr)
library(jsonlite)
library(xml2)
ensembl = useEnsembl(biomart="ensembl", dataset="hsapiens_gene_ensembl", GRCh=37)
listAttributes(ensembl)
transcripts <- getBM(attributes = c('refseq_mrna', 'ensembl_transcript_id'),
                     mart=ensembl) %>%
  filter(refseq_mrna != '')

get_position <- function(translocation_name){
  split_list = str_split(translocation_name, pattern="[{}]")[[1]]
  # Ensembl or refseq
  # so far ignoring refseq
  trans1 = split_list[2]
  # start and end
  c_dna1 = str_split(split_list[3], pattern=":r.|_")[[1]][2:3]
  trans2 = split_list[4]
  c_dna2 = str_split(split_list[5], pattern=":r.|_")[[1]][2:3]
  print(trans1)
  if(!(is.na(trans1) | is.na(trans2))){
    if(str_detect(trans1, "NM_*")){
      refseq <- str_split(trans1, pattern="\.")[1]
      print(refseq)
      trans1 <- transcripts %>%
        filter(refseq_mrna == refseq)[1,1]
    }
    if(str_detect(trans2, "NM_*")){
      refseq <- str_split(trans2, pattern="\.")[1]
      trans2 <- transcripts %>%
        filter(refseq_mrna == refseq)[1,1]
    }

  }

  if(any(is.na(c(trans1,c_dna1,trans2,c_dna2)))){
    return(data.frame(rbind(c(start1 = NA, end1=NA, strand1=NA, chrom1=NA,
                     start2 = NA, end2=NA, strand2=NA, chrom2=NA))))
  }
  else{
    server <- "http://grch37.rest.ensembl.org"
    query1 <- paste("/map/cdna/", trans1, "/",c_dna1[1], "..", c_dna1[2],"?",
                    sep="")
    r1 <- GET(paste(server, query1, sep = ""), content_type("application/json"))

    stop_for_status(r1)
    out1 <- fromJSON(toJSON(content(r1)))$mappings %>%
      mutate(strand = if_else(strand == 1,
                              '+', '-', '.')) %>%
      rename(chrom1 = seq_region_name,
             start1 = start,
             end1 = end,
             strand1 = strand) %>%
      dplyr::select(matches("*1")) %>%
      slice(1)

    query2 <- paste("/map/cdna/", trans2, "/",c_dna2[1], "..", c_dna2[2],"?",
                    sep="")

    r2 <- GET(paste(server, query2, sep = ""), content_type("application/json"))

    stop_for_status(r2)
    out2 <- fromJSON(toJSON(content(r2)))$mappings %>%
      mutate(strand = if_else(strand == 1,
                              '+', '-', '.')) %>%
      rename(chrom2 = seq_region_name,
             start2 = start,
             end2 = end,
             strand2 = strand) %>%
      dplyr::select(matches("*2")) %>%
      slice(1)

    output <- out1 %>%
      bind_cols(out2) %>%
      mutate(`Translocation Name` = translocation_name)

    return(output)
  }
}

input_file <- "CosmicFusionExport.tsv"

cosmic_bedpe <- read_tsv(input_file)

test <- cosmic_bedpe %>%
  sample_n(20) %>%
  rowwise() %>%
  mutate(temp = list(get_position(`Translocation Name`))) %>%
  mutate(start1 = temp$start1 ) %>%
  mutate(end1 = temp$start1 ) %>%
  mutate(chrom1 = temp$chrom1) %>%
  mutate(start2 = temp$start2 ) %>%
  mutate(end2 = temp$start2 ) %>%
  mutate(chrom2 = temp$chrom2)

get_position(test$`Translocation Name`[2])
try = test$`Translocation Name`[2]
hm <- unlist(try)
list(c(NA))
hm[1]
get_position(cosmic_bedpe$`Translocation Name`[2])
