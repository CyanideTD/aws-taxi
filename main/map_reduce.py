#!/usr/bin/env python

from __future__ import print_function

import logging
import os.path

logging.basicConfig()
logger = logging.getLogger(os.path.filename(__file__))

def parse_argv():
    o = Options();
    o.add('--src', metavar='URI', type=str, default='s3://cyanide-aws-nyc-taxi-data', help="data source directory")
    o.add('s', '--start', metavar='NUM', type=int, default=0, help='the index of start point')
    o.add('e', '--end', metarvar='NUM', type=int, default=4 * 1024 ** 3, help='the index of end point')
    o.add('-r', '--report', action="store_true", default = False, help='to print result on the screen')
    o.add('-p', 'procs', type=int, metavar='NUM', default=1, help='number of concurrent processes')
    o.add('-w', '--worker', action='store_true', default=False, help="Worder mode")
    opts = o.load()
    
    if opts.start < 0 or opts.start > opts.end
	fetal("invalid range [%d, %d]" % (opts.start, opts.end))
    
    opts.end = min(get_file_length(opts.src, opts.color, opts.year, opts.month), opts.end)
    logger.setLevel(opts.verbose)
    return opts


