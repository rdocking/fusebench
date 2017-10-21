#!/usr/bin/env r
require(tidyverse)
require(stringr)
#takes in chimerseq .csv file from download and puts the output in bedpe format, with platform-specific columns following the bedpe columns

# Parse command-line arguments
options(echo=TRUE)
args <- commandArgs(trailingOnly = TRUE)
print(args)

input_file <- args[1]
output_file <- args[2]

chimerseq_to_bedpe <- function(input_file, output_file){

  dat<-read.csv(input_file, stringsAsFactors=F, header=TRUE)
  colnames(dat) <- gsub("H_strand", "strand1", colnames(dat))
  colnames(dat) <- gsub("T_strand", "strand2", colnames(dat))
  colnames(dat) <- gsub("H_chr", "chrom1", colnames(dat))
  colnames(dat) <- gsub("T_chr", "chrom2", colnames(dat))
  colnames(dat) <- gsub("Fusion_pair", "name", colnames(dat))
  dat$name <- gsub("_","-", dat$name)
  
  colnames(dat) <- gsub("H_position", "start1", colnames(dat))
  colnames(dat) <- gsub("T_position", "start2", colnames(dat))
  colnames(dat) <- gsub("H_locus", "locus1", colnames(dat))
  colnames(dat) <- gsub("T_locus", "locus2", colnames(dat))
 
  #index ordered at 0, add 1 for end of break
  dat <- dat %>% mutate(end1 = as.numeric(start1)+1)
  dat <- dat %>% mutate(end2 = as.numeric(start2)+1)
  dat$score <- "0"
  #gene fusion name
  dat <- select(dat, c(-id,-T_gene,-H_gene))
  #order of bedpe columns
  bedcol <- c('chrom1', 'start1', 'end1', 'chrom2', 'start2', 'end2', 'name', 'score', 'strand1', 'strand2')
  #get column numbers to reorder
  num<-NULL
  for (i in bedcol){num<-append(num,which(colnames(dat)==i))}
  #reorder columns
  dat <- select(dat, num, which(!colnames(dat) %in% bedcol))
  write.table(dat,output_file, sep = "\t")
}

chimerseq_to_bedpe(input_file, output_file)
