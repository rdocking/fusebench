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
  #multiple fusions appear in one cell, count out and separate them
  n <- max(str_count(dat[grepl("\\|",dat$Junction),c("Junction")],"\\|"))
  dat <-  separate(dat, Junction, into= c(paste0(rep("Fusion", n+1),1:(n+1))), sep = "\\|") %>% select(-A_chr, -B_chr)
  #Copy extra rows into the table such that there is one for each different fusion, then get rid of extra columns
  while (n+1>1) {
  copy <- dat[complete.cases(dat[,which(colnames(dat)==paste0("Fusion", (n+1)))]),]
  copy[,"Fusion1"] <-  copy[,which(colnames(dat)==paste0("Fusion", (n+1)))] 
  dat <- bind_rows(dat,copy) %>% select(-which(colnames(dat)==paste0("Fusion", (n+1))))
  n=n-1
  }
  #separate the master cell to get at the coordinates
  dat <-  separate(dat, Fusion1, into= c("gene1", "chrom1", "start1", "chrom2", "start2"), sep = ":")
  dat$start2 <- gsub(",.*", "", dat$start2)
  dat$start1 <- gsub("_.*", "", dat$start1)
  #index ordered at 0, add 1 for end of break
  dat <- dat %>% mutate(end1 = as.numeric(start1)+1)
  dat <- dat %>% mutate(end2 = as.numeric(start2)+1)
  dat$score <- "0"
  #gene fusion name
  dat <- unite(dat, name, Gene_A, Gene_B, sep = "-")
  dat <- select(dat, -gene1)
  #order of bedpe columns
  bedcol <- c('chrom1', 'start1', 'end1', 'chrom2', 'start2', 'end2', 'name', 'score', 'strand1', 'strand2')
  #get column numbers to reorder
  num<-NULL
  for (i in bedcol){num<-append(num,which(colnames(dat)==i))}
  #reorder columns
  dat <- select(dat, num, which(!colnames(dat) %in% bedcol))
  write.csv(dat,output_file, row.names=F)
}

chimerseq_to_bedpe(input_file, output_file)