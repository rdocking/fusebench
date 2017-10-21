'''
Convert SOAPfuse output to BEDPE format.

Can be run from the commandline with:
    python soapfuse_to_bedpe.py -i <input_file> -o <output_file>

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

    out_row['chrom1'] = input_row['up_chr']
    out_row['start1'] = input_row['up_Genome_pos'] # assuming 0-based
    out_row['end1'] = int(input_row['up_Genome_pos']) + 1
    out_row['strand1'] = input_row['up_strand']

    out_row['chrom2'] = input_row['dw_chr']
    out_row['start2'] = input_row['dw_Genome_pos'] # assuming 0-based
    out_row['end2'] = int(input_row['dw_Genome_pos']) + 1
    out_row['strand2'] = input_row['dw_strand']

    gene1 = input_row['up_gene']
    gene2 = input_row['dw_gene']
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
    to_add = ['up_loc', 'dw_loc', 'Span_reads_num', 'Junc_reads_num',
                'Fusion_Type', 'down_fusion_part_frame-shift_or_not']
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
    Convert SOAPfuse output to BEDPE format.
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
            fieldnames = add_fields(init_fieldnames)
            writer = csv.DictWriter(outf, fieldnames=fieldnames,
                                    lineterminator='\n', delimiter='\t')
            writer.writeheader()
            for in_row in reader:
                out_row = map_fields(in_row, fieldnames)
                writer.writerow(out_row)
    return 0




if __name__ == '__main__':
    main()
