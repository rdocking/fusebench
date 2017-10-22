#!/usr/bin/env r
# Use data.table to merge two BEDPE files

library(data.table)

# Initial example - filtered simple set
slop <- 10

left.dt <- fread('left.tsv')
right.dt <- fread('right.tsv')

# Add slop to 'y' data table
right.dt$start1 <- right.dt$start1 - slop
right.dt$end1 <- right.dt$end1 + slop
right.dt$start2 <- right.dt$start2 - slop
right.dt$end2 <- right.dt$end2 + slop

# Set keys on right data frame
setkey(right.dt, 
       chrom1, start1, end1, 
       chrom2, start2, end2)

# Use foverlaps to find overlaps
foverlaps(left.dt, right.dt, 
          by.x = c("chrom1", "start1", "end1", "chrom2", "start2", "end2"),
          by.y = c("chrom1", "start1", "end1", "chrom2", "start2", "end2"),
          type = "any", which = TRUE)
