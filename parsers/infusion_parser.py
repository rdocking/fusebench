import math, csv, sys
from collections import defaultdict
import getopt, argparse

def grabInfusion(filename, outputname):
    f=open(filename,"r")
    lines=f.readlines()
    row_list = []

    for element in lines:

        string = ' '.join(element.split())
        row = string.split(' ')
        try:
            chrom1 = row[1]
            chrom2 = row[4]
            startbase1 = int(row[2])
            endbase1 = int(row[2])
            startbase2 = int(row[5])
            endbase2 = int(row[5])
            name = row[0]
            score = 0
            strand1 = '.'
            strand2 = '.'
            program = 'infusion'
            endbase1 = endbase1 + 1
            endbase2 = endbase2 + 1

            test = (chrom1, str(startbase1), str(endbase1), chrom2, str(startbase2), str(endbase2), name, str(score), strand1, strand2, program)
            row_list.append(test)
        except:
            print("Error: invalid column names (check first column of txt file)")
    return row_list

def main():
    filename = raw_input('Enter filename: ')
    print(filename)
    if filename.endswith('.txt'):
        outputname = raw_input('Enter output filename: ')
        output_file = str(outputname) + ".bedpe"
        info = grabInfusion(filename, outputname)
        print("asterix rawr XD")
        print(info)
        with open(output_file, "a") as myfile:
            for element in info:
                element = str(element).replace("(", "")
                element = str(element).replace(")", " \n")
                myfile.write(str(element))

if __name__ == '__main__':
    main()
