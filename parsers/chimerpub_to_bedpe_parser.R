#!/usr/bin/env r
require(tidyverse)
require(stringr)

#takes in chimerpub .csv file from download and puts the output in bedpe format, with platform-specific columns following the bedpe columns

# Parse command-line arguments
options(echo=TRUE)
args <- commandArgs(trailingOnly = TRUE)
print(args)

input_file <- args[1]
output_file <- args[2]

chimerpub_to_bedpe <- function(input_file, output_file){

  dat<-read.csv(input_file,stringsAsFactors=F, header=TRUE)
  #not much bedpe info in this file
  dat$strand1 <- "."
  dat$strand2 <- "."
  dat$chrom1 <- "."
  dat$chrom2 <- "."
  dat$start1 <- 0
  dat$start2 <- 0
  dat$end1 <- 0
  dat$end2 <- 0
  colnames(dat) <- gsub("Fusion_pair", "name", colnames(dat))
  dat$name <- gsub("_","-", dat$name)
  
  colnames(dat) <- tolower(colnames(dat))
 
  #order of bedpe columns
  bedcol <- c('chrom1', 'start1', 'end1', 'chrom2', 'start2', 'end2', 'name', 'score', 'strand1', 'strand2')
  #get column numbers to reorder
  num<-NULL
  for (i in bedcol){num<-append(num,which(colnames(dat)==i))}
  #reorder columns
  colnames(dat)[1] <- "id"
  dat <- select(dat, num, which(!colnames(dat) %in% bedcol)) %>% select(-id, -h_gene, -t_gene)
  write.table(dat,output_file, sep = "\t")
}

chimerpub_to_bedpe(input_file, output_file)
