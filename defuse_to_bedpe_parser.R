#!/usr/bin/env r
require(tidyverse)

#takes in results.filtered.tsv files from defuse and puts the output in bedpe format, with platform-specific columns following the bedpe columns

# Parse command-line arguments
options(echo=TRUE)
args <- commandArgs(trailingOnly = TRUE)
print(args)

input_file <- args[1]
output_file <- args[2]

defuse_to_bedpe <- function(input_file, output_file){

  dat<-read.table(input_file, sep = "\t", stringsAsFactors=F, header=TRUE)

defuse_to_bedpe <- function(input_file, output_file){
  
  dat<-read.table(input_file, sep = "\t", stringsAsFactors=F, header=TRUE)
  
  colnames(dat) <- gsub("gene_strand1", "strand1", colnames(dat))
  colnames(dat) <- gsub("gene_strand2", "strand2", colnames(dat))
  colnames(dat) <- gsub("gene_chromosome", "chrom", colnames(dat))
  colnames(dat) <- gsub("genomic_break_pos1", "start1", colnames(dat))
  colnames(dat) <- gsub("genomic_break_pos2", "start2", colnames(dat))
  #index ordered at 0, add 1 for end of break
  dat <- dat %>% mutate(end1 = start1+1)
  dat <- dat %>% mutate(end2 = start2+1)
  dat$score <- "0"
  #gene fusion name
  dat <- unite(dat, name, gene_name1, gene_name2, sep = "-")
  #order of bedpe columns
  bedcol <- c('chrom1', 'start1', 'end1', 'chrom2', 'start2', 'end2', 'name', 'score', 'strand1', 'strand2')
  #get column numbers to reorder
  num<-NULL
  for (i in bedcol){num<-append(num,which(colnames(dat)==i))}
  #reorder columns
  dat <- select(dat, num, which(!colnames(dat) %in% bedcol))
  write_tsv(dat, output_file)
}

defuse_to_bedpe(input_file, output_file)

