#!/bin/bash
set -e -x -o pipefail

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

bedtools pairtopair -a ${database1} -b ${database2} \
  -type neither > ${neither1}

# Append d1
awk -v var="$d1" '{print $0,var}' OFS='\t' ${neither1} > tmp_${neither1}

bedtools pairtopair -a ${database1} -b ${database2} \
    -type either > ${either1}
# Append d1
awk -v var="$d1" '{print $0,var}' OFS='\t' ${either1} > tmp_${either1}

bedtools pairtopair -a ${database2} -b ${database1} \
  -type neither > ${neither2}
# Append d2
awk -v var="$d2" '{print $0,var}' OFS='\t' ${neither2} > tmp_${neither2}

bedtools pairtopair -a ${database1} -b ${database1} \
    -type either > ${either2}
# Append d2
awk -v var="$d2" '{print $0,var}' OFS='\t' ${either2} > tmp_${either2}

cat tmp_${both} tmp_${either1} tmp_${neither1} tmp_${either2} tmp_${neither2}\
  > ${d1}_${d2}_annotations.bedpe
