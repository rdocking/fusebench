
'''
Convert Validate BEDPE format.

Can be run from the commandline with:
    python validate_bedpe.py -i <input_file>

If no <input_file> and/or <output_file> is specified, the file will read/write
from/to STDIN/STDOUT, allowing for piping into and out of the program.
'''

import argparse,sys,csv

def validate_row(input_row):
    '''
    Check if the the row complies with the BEDPE standard

    Args:
        input_row (dict): {'heading': value} one row in input
    Returns:
        bool: the return value. true if a valid row false otherwise
    '''

    #only read required columns
    try:
        ch1 = input_row['chrom1']
        start1 = input_row['start1']
        end1 = input_row['end1']
        ch2 = input_row['chrom2']
        start2 = input_row['start2']
        end2 = input_row['end2']
    except:
        print("All required keys are not present")
        return False


    if((not start1.lstrip('-+').isdigit()) or (not end1.lstrip('-+').isdigit()) or (not start2.lstrip('-+').isdigit()) or (not end2.lstrip('-+').isdigit())):
        print("positions are not digits start1:{}, end1:{}, start2:{}, end2:{}".format(start1,end1, start2, end2))
        return False
    elif((int(start1) < -1) or (int(end1) < -1) or (int(start2) < -1) or (int(end2) < -1)):
        print("positions are < -1")
        return False

    return True




def get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', dest='inf', metavar='<in-file>',
                        help='File to parse (default STDIN)')
    return parser


def main():
    '''
    Validate BEDPE format.
    '''
    # Get args
    parser = get_parser()
    args = parser.parse_args()
    with open(args.inf, 'r') if args.inf else sys.stdin as inf:
        reader = csv.DictReader(filter(lambda row: row[0] != '#', inf), delimiter='\t')

        # Output is always BEDPE

        line = 0

        for in_row in reader:
            if(not validate_row(in_row)):
                print("not a valid line, breaks at line {}\n{}".format(line,in_row))
                break
            line += 1

    print("#lines: {}".format(line))
    print("Valid BEDPE file")
    return 0




if __name__ == '__main__':
    main()
