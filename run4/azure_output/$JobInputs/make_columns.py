# This script will make columns of the same dimension as input file.
# It will make two columns: run and repeat, delimited by comma
#
# python make_columns.py --input infile.txt --repeat 1 --run 1
import argparse as arg

def get_num_lines(filename):
    num_lines = sum(1 for line in open(filename))
    return(num_lines)


def make_repeated_line(run, repeat, lines):
    lines = ["{0},{1}".format(run, repeat) for i in range(lines)]
    lines = ["\"run\",\"repeat\""] + lines
    text = "\n".join(lines)
    return(text)


def main(args):
    num_lines = get_num_lines(args.input)
    text = make_repeated_line(args.run, args.repeat, num_lines-1)
    print(text)


def parse_args():
    parser = arg.ArgumentParser(
        prog="make_columns.py",
        description=("")
        )
    parser.add_argument(
        "-i", "--input", required=True, type=str,
        help=("File for which columns are constructed.")
        )
    parser.add_argument(
        "-r", "--repeat", required=True, type=int,
        help=("value in column \"repeats\"")
        )
    parser.add_argument(
        "-u", "--run", required=True, type=int,
        help=("value in column \"run\"")
        )
    args = parser.parse_args()
    return(args)


if __name__ == "__main__":
    args = parse_args()
    main(args)
