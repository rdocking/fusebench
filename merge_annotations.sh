#!/bin/bash
set -e -x -o pipefail
###############################################################################
# The following script is an example of merging BEDPE files and annotating each
# row with the database in which a particular paired feature was found.
#
# Features present in both databases will be reported with respect to the first
# argument. The final result has no heading, and annotations associated with a
# particular database are ignored.
#
# The last column of the resulting file indicates the file(s)  in which the
# observation was originally found.
###############################################################################

usage="Usage: ./merge_annotations.sh file1.bedpe file2.bedpe"

if [ -z $1 ]; then
  echo $usage
  exit
fi

if [ -z $2 ]; then
  echo $usage
  exit
fi

d1="${1%.*}"
d2="${2%.*}"

database1="trim_${1}"
database2="trim_${2}"

cut $1 -f1-10 > ${database1}
cut $2 -f1-10 > ${database2}

both="${d1}_${d2}_both.bedpe"
neither1="${d1}_${d2}_neither.bedpe"
either1="${d1}_${d2}_either.bedpe"
neither2="${d2}_${d1}_neither.bedpe"
either2="${d2}_${d1}_either.bedpe"

bedtools pairtopair -a ${database1} -b ${database2} > ${both}

# Append d1,d2
awk -v var="$d1,$d2" '{print $0,var}' OFS='\t' ${both} > tmp_${both}

bedtools pairtopair -a ${database1} -b ${database2} -type neither > ${neither1}

# Append d1
tail -n+2 ${neither1} | awk -v var="$d1" '{print $0,var}' OFS='\t' > tmp_${neither1}

bedtools pairtopair -a ${database1} -b ${database2} -type either > ${either1}
# Append d1
tail -n+2 ${either1} | awk -v var="$d1" '{print $0,var}' OFS='\t' > tmp_${either1}

bedtools pairtopair -a ${database2} -b ${database1} -type neither > ${neither2}
# Append d2
tail -n+2 ${neither2} | awk -v var="$d2" '{print $0,var}' OFS='\t' > tmp_${neither2}

bedtools pairtopair -a ${database1} -b ${database1} -type either > ${either2}
# Append d2
tail -n+2 ${either2} | awk -v var="$d2" '{print $0,var}' OFS='\t'  > tmp_${either2}

# Concatenate results into merged annotations file
cat tmp_${both} tmp_${either1} tmp_${neither1} tmp_${either2} tmp_${neither2}\
  > ${d1}_${d2}_annotations.bedpe

# Remove intermediate files
to_remove=( tmp_${both}
            tmp_${either1}
            tmp_${neither1}
            tmp_${either2}
            tmp_${neither2}
            ${both}
            ${either1}
            ${neither1}
            ${either2}
            ${neither2}
            ${database1}
            ${database2})

for file in "${to_remove[@]}"; do
  rm ${file}
done
