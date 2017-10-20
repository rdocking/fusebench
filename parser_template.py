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

    [chr1, pos1, strand1 ] = input_row['Fusion_point_for_gene_1(5end_fusion_partner)'].split(':')
    out_row['chrom1'] = 'chr{num}'.format(num=chr1)
    out_row['start1'] = int(pos1) - 1 # 1-based
    out_row['strand1'] = strand1

    [chr2, pos2, strand2] = input_row['Fusion_point_for_gene_2(3end_fusion_partner)'].split(':')
    out_row['chrom2'] = 'chr{num}'.format(num=chr2)
    out_row['start2'] = pos2
    out_row['strand2'] = strand2

    gene1 = input_row['Gene_1_symbol(5end_fusion_partner)']
    gene2 = input_row['Gene_2_symbol(3end_fusion_partner)']
    out_row['name'] = '{G1}-{G2}'.format(G1=gene1, G2=gene2)

    out_row['score'] = '.'

    for heading in headings:
        if (heading not in out_row) and (heading in input_row):
            out_row[heading] = input_row[heading]
        else:
            out_row[heading] = '.'
    return out_row


def add_fields(bedpe_fields):
    '''Add fields from input to end of BEDPE format'''
    to_add = ['Fusion_description', 'Counts_of_common_mapping_reads',
            'Spanning_pairs', 'Spanning_unique_reads',
            'Longest_anchor_found','Fusion_finding_method',
            'Gene_1_id(5end_fusion_partner)', 'Gene_2_id(3end_fusion_partner)',
            'Exon_1_id(5end_fusion_partner)', 'Exon_2_id(3end_fusion_partner)',
            'Fusion_sequence', 'Predicted_effect']
    return bedpe_fields + to_add


def get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', dest='input_file', metavar='<in-file>',
                        type=argparse.FileType('r'), default=sys.stdin
                        help='File to parse (default STDIN)')
    parser.add_argument('-o', dest='output_file', metavar='<out-file>',
                        type=argparse.FileType('w'), default=sys.stdout
                        help='Output BEDPE destination (default STDOUT)')
    return parser


def main():

    # Get args
    parser = get_parser()
    args = parser.parse_args()
    with open(args.input_file, 'r') as inf, open(args.output_file, 'w') as outf:

        #
        # Organize I/O
        #

        # Input file is tab delimited plus heading
        dialect = csv.Sniffer.sniff(inf.readline(), delimiters='\t')
        inf.seek(0)
        reader = csv.DictReader(inf, dialect)

        # Output is always BEDPE
        init_fieldnames = ['chrom1', 'start1', 'end1', 'chrom2', 'start2',
                            'end2', 'name', 'score', 'strand1', 'strand2']
        fieldnames = add_fields(init_fieldnames)
        writer = csv.DictWriter(outf, fieldnames=fieldnames)
        writer.writeheader()
        for in_row in reader:
            out_row = map_fields(heading,in_row)
            writer.writerow(out_row)
    return 0




if __name__ == '__main__':
    main()
