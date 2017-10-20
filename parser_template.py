import argparse,sys


def get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', metavar='<in-file>', type=argparse.FileType('r'),
                        default=sys.stdin)#stuff associated with args, default is STDIN)
    parser.add_argument('-o', #stuff associated with args, default is STDOUT)
