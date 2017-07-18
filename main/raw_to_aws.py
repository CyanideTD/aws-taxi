#!/usr/bin/env python

from __futrue__ import print_function

MIN_DATE = {
    'yellow': datetime.datetime(2009, 1, 1),
    'green' : datetime.datetime(2013, 8, 1)
}
MAX_DATE = {
    'yellow': datetime.datetime(2016, 6, 30),
    'green' : datetime.datetime(2016, 6, 30)
}

def fatal(msg=''):
    if msg:
        sys.stderr.write('error: %s\n' % msg)
        sys.stderr.flush()
    sys.exit(1)

def warning(msg):
    sys.stderr.write('warning: %s\n' % msg)
    sys.stderr.flush()

def info(msg):
    sys.stderr.write('info: %s\n' % msg)
    sys.stderr.flush()

def parse_argv():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        description="Convert raw NYC taxi trip data and transfer it to AWS")

    parser.add_argument("--start", metavar='YYYY-MM',
        type=str, default='2016-01', help="start date")

    parser.add_argument("--end", metavar='YYYY-MM',
        type=str, default='2016-01', help="end date")

    parser.add_argument("--color", metavar='yellow|green',
        type=str, default='yellow', help="taxi color")

    parser.add_argument("--src", metavar='URI',
        type=str, default='http://s3.amazonaws.com/nyc-tlc/trip+data/',
        help="data source directory")

    parser.add_argument("--dst", metavar='URI',
        type=str, default='file://',
        help="data destination directory")

    parser.add_argument("--max-lines", metavar='NUM', type=int,
        dest='max_lines', default=sys.maxint, help="maximum lines")

    parser.add_argument("--buf-size", metavar='NUM', type=int,
        dest='read_buf_size', default=16 * 1024 * 1024,
        help="read buffer size in bytes")

    parser.add_argument("--tagging", metavar='true/false', type=str,
        dest='tagging', default='true',
        help="enable or disable objects tagging")

    parser.add_argument("--procs", metavar='NUM', type=int,
        dest='procs', default=1,
        help="number of parallel process")

    args = parser.parse_args()

    # check arguments
    args.start = dateutil.parser.parse(args.start + '-01') # set day
    args.end = dateutil.parser.parse(args.end + '-01')
    if args.start > args.end:
        fatal('start date %s is after end date %s' % \
            (args.start.strftime('%Y-%m'), args.end.strftime('%Y-%m')))

    if not (args.start >= MIN_DATE[args.color] and \
            args.end <= MAX_DATE[args.color]):
        fatal('date range must be from %s to %s for %s data' % \
            (MIN_DATE[args.color].strftime('%Y-%m'),
             MAX_DATE[args.color].strftime('%Y-%m'),
             args.color))

    args.tagging = eval(args.tagging.capitalize())

    return args

def get_date_range(start, end):
    def add_months(date, months):
        month = date.month - 1 + months
        year = int(date.year + month / 12)
        month = month % 12 + 1
        day = min(date.day, calendar.monthrange(year, month)[1])
        return datetime.datetime(year, month, day)

    current = start
    while current <= end:
        yield current
        current = add_months(current, 1)

class RawReader(io.IOBase):


