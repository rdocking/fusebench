'''
Convert Pancreatic Cancer Action Network (PanCan) Database format to BEDPE format.

Can be run from the commandline with:
    python pancan_to_bedpe.py -i <input_file> -o <output_file>

If no <input_file> and/or <output_file> is specified, the file will read/write
from/to STDIN/STDOUT, allowing for piping into and out of the program.
'''

import argparse,sys,csv,codecs
sys.stdin = codecs.getreader('utf8')(sys.stdin)
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

    out_row['chrom1'] = 'chr{num}'.format(num=input_row['A_chr'])
    out_row['start1'] = input_row['gene_A_start'] # assuming 0-based
    out_row['end1'] = int(input_row['gene_A_end'])

    A_strand = int(input_row['A_strand'])
    out_row['strand1'] = '-' if A_strand == -1 else '+' if A_strand == 1 else '.'

    out_row['chrom2'] = 'chr{num}'.format(num=input_row['B_chr'])
    out_row['start2'] = input_row['gene_B_start'] # assuming 0-based
    out_row['end2'] = int(input_row['gene_B_end'])

    B_strand = int(input_row['B_strand'])
    out_row['strand2'] = '-' if B_strand == -1 else '+' if B_strand == 1 else '.'

    gene1 = input_row['Gene_A']
    gene2 = input_row['Gene_B']
    out_row['name'] = '{G1}-{G2}'.format(G1=gene1, G2=gene2)

    out_row['score'] = 0

    for heading in headings:
        if (heading not in out_row) and (heading in input_row):
            out_row[heading] = input_row[heading]
        elif heading not in out_row:
            out_row[heading] = '.'
    return out_row


def add_fields(bedpe_fields):
    '''Add fields from input to end of BEDPE format'''
    to_add = [ 'WGS', 'Evalue', 'sampleId', 'Junction_B', 'Junction_A', 'id',
                'centrality','Discordant_n', 'frame', 'phos_A', 'phos_B','tier',
                'ubiq_A', 'ubiq_B', 'Cancer', 'perfectJSR_n', 'JSR_n']
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
    Convert PanCan Database file to BEDPE format.
    '''
    # Get args
    parser = get_parser()
    args = parser.parse_args()
    with open(args.inf, 'rU') if args.inf else sys.stdin as inf:
        with open(args.outf, 'w') if args.outf else sys.stdout as outf:
            #
            # Organize I/O
            #

            # Input file is tab delimited plus heading
            reader = csv.DictReader(inf, delimiter='\t')

            # Output is always BEDPE
            init_fieldnames = ['chrom1', 'start1', 'end1', 'chrom2', 'start2',
                                'end2', 'name', 'score', 'strand1', 'strand2']
            fieldnames = add_fields(init_fieldnames)
            writer = csv.DictWriter(outf, fieldnames=fieldnames, delimiter='\t')
            writer.writeheader()
            for in_row in reader:
                out_row = map_fields(in_row, fieldnames)
                writer.writerow(out_row)
    return 0




if __name__ == '__main__':
    main()
