import math, csv, sys
from collections import defaultdict
import getopt, argparse

def grabJaffa(filename, outputname):

    with open(filename, mode='r') as f:
        rows = []
        reader = csv.DictReader(f) # read rows into a dictionary format
        for row in reader: # read a row as {column1: value1, column2: value2,...}
            try:
                chrom1 = row['chrom1']
                chrom2 = row['chrom2']
                startbase1 = int(row['base1'])
                endbase1 = int(row['base1'])
                startbase2 = int(row['base2'])
                endbase2 = int(row['base2'])
                name = row['sample']
                score = 0
                strand1 = '.'
                strand2 = '.'
                program = 'jaffa'
                endbase1 = endbase1 + 1
                endbase2 = endbase2 + 1

                test = (chrom1, str(startbase1), str(endbase1), chrom2, str(startbase2), str(endbase2), name, str(score), strand1, strand2, program)
                rows.append(test)
            except:
                print("Error: invalid column names (check first column of csv file)")
    return rows
    
int main():
  filename = raw_input('Enter filename: ')
  print(filename)
  if filename.endswith('.csv'):
      outputname = raw_input('Enter output filename: ')
      output_file = str(outputname) + ".bedpe"
      info = grabJaffa(filename, outputname)
      with open(output_file, "a") as myfile:
          for element in info:
              element = str(element).replace("(", "")
              element = str(element).replace(")", " \n")
              myfile.write(str(element))
