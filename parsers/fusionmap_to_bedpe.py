'''
Convert FusionMap output to BEDPE format.

Can be run from the commandline with:
    python fusionmap_to_bedpe.py -i <input_file> -o <output_file>

If no <input_file> and/or <output_file> is specified, the file will read/write
from/to STDIN/STDOUT, allowing for piping into and out of the program.
'''

import argparse,sys,csv,codecs

sys.stdin = codecs.getreader('utf8')(sys.stdin)
sys.stdout = codecs.getwriter('utf8')(sys.stdout)

def map_fields(input_row, headings):
    '''
    Map fields from the input row to bedpe_fields

    Args:
        input_row (dict): {'heading': value} mapping for one row in input
        headings (list): A list of all BEDPE headings to include
    Returns:
        dict: the return value. A single BEDPE row
    '''
    out_row = dict()

    out_row['chrom1'] = 'chr{num}'.format(num=input_row['Chromosome1'])
    out_row['start1'] = input_row['Position1'] # assuming 0-based
    out_row['end1'] = int(input_row['Position1']) + 1
    out_row['strand1'] = input_row['Strand'][0]

    out_row['chrom2'] = 'chr{num}'.format(num=input_row['Chromosome2'])
    out_row['start2'] = input_row['Position2'] # assuming 0-based
    out_row['end2'] = int(input_row['Position2']) + 1
    out_row['strand2'] = input_row['Strand'][1]

    gene1 = input_row['KnownGene1']
    gene2 = input_row['KnownGene2']
    out_row['name'] = '{G1}-{G2}'.format(G1=gene1, G2=gene2)

    out_row['score'] = 0

    for heading in headings:
        if (heading not in out_row) and (heading in input_row):
            out_row[heading] = input_row[heading]
        elif heading not in out_row:
            out_row[heading] = '.'
    return out_row


def add_fields(bedpe_fields, input_fields):
    '''Add fields from input to end of BEDPE format'''
    to_add = []
    specified_fields = ['Chromosome1', 'Chromosome2', 'Position1', 'Position2',
                        'Strand', 'KnownGene1', 'KnownGene2']
    #add all but specified fields
    to_add += [elem for elem in input_fields if elem not in specified_fields]
    return bedpe_fields + to_add


def get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', dest='inf', metavar='<in-file>',
                        help='File to parse (default STDIN)')
    parser.add_argument('-o', dest='outf', metavar='<out-file>',
                        help='Output BEDPE destination (default STDOUT)')
    return parser


def main():
    '''
    Convert FusionMap output to BEDPE format.
    '''
    # Get args
    parser = get_parser()
    args = parser.parse_args()
    with open(args.inf, 'rU') if args.inf else sys.stdin as inf:
        with open(args.outf, 'wb') if args.outf else sys.stdout as outf:
            #
            # Organize I/O
            #

            # Input file is tab delimited plus heading
            reader = csv.DictReader(inf, delimiter='\t')

            # Output is always BEDPE
            init_fieldnames = ['chrom1', 'start1', 'end1', 'chrom2', 'start2',
                                'end2', 'name', 'score', 'strand1', 'strand2']
            fieldnames = add_fields(init_fieldnames, reader.fieldnames)
            writer = csv.DictWriter(outf, fieldnames=fieldnames,
                                    lineterminator='\n', delimiter='\t')
            writer.writeheader()
            for in_row in reader:
                out_row = map_fields(in_row, fieldnames)
                writer.writerow(out_row)
    return 0




if __name__ == '__main__':
    main()
