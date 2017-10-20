'''
Convert StarFusion output to BEDPE format.

Can be run from the commandline with:
    python star_fusion_to_bdpe.py -i <input_file> -o <output_file>

If no <input_file> and/or <output_file> is specified, the file will read/write
from/to STDIN/STDOUT, allowing for piping into and out of the program.
'''

import argparse,sys,csv

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

    [chr1, pos1, strand1] = input_row['LeftBreakpoint'].split(':')
    out_row['chrom1'] = chr1
    out_row['start1'] = int(pos1) - 1 # FIXME: check if this is 1-based
    out_row['end1'] = pos1
    out_row['strand1'] = strand1

    [chr2, pos2, strand2] = input_row['RightBreakpoint'].split(':')
    out_row['chrom2'] = chr2
    out_row['start2'] = int(pos2) - 1 # FIXME: check if 1-based
    out_row['end2'] = pos2
    out_row['strand2'] = strand2

    out_row['name'] = input_row['#FusionName']

    out_row['score'] = 0

    for heading in headings:
        if (heading not in out_row) and (heading in input_row):
            out_row[heading] = input_row[heading]
        elif heading not in out_row:
            out_row[heading] = '.'
    return out_row


def add_fields(bedpe_fields):
    '''Add fields from input to end of BEDPE format'''
    to_add = ["JunctionReadCount", "SpanningFragCount", 
              "SpliceType", "LeftGene", "RightGene", 
              "LargeAnchorSupport", "LeftBreakDinuc", 
              "LeftBreakEntropy", "RightBreakDinuc", 
              "RightBreakEntropy", "J_FFPM", "S_FFPM"]
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
    Convert StarFusion output to BEDPE format.
    '''
    # Get args
    parser = get_parser()
    args = parser.parse_args()
    with open(args.inf, 'r') if args.inf else sys.stdin as inf:
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
