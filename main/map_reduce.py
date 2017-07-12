#!/usr/bin/env python

from __future__ import print_function

import logging
import os.path
from common import *

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

#class that read from file
class RecordReader(io.IOBase):
    DATA_FILE = 1
    DATA_S3 = 2

    def __init__(self):
	self.data = None
	self.start = 0
	self.end = 0
	self.data_type = -1
	self.s3 = boto3.resource('s3')
	self.client = boto3.client('s3')
	self.path = ''
	self.proc = multiprocessing.current_process().name
	
    #open the file
    def open(self, color, year, month, source, start, end):
	self.start = start
	self.end = end
	self,skip = None
	filename = get_file_name(color, year, month)
	
	if source.startwwith('file://'):
	    self.data_type = self.DATA_FILE
	    directory = os.path.realpath(source[7:])
	    path = "%s/%s" % (directory, file_name)
	    self.path = 'file://' + path
	    self.data = open(path, 'r')
	    self.data.seek(RECORD_LENGTH * self.start)
	else:
	    self.data_type = self.DATA_S3
	    bucket = self.s3.Bucket(source[5:])
	    obj = bucket.Object(filename)
	    self.path = 's3://%s/%s' % (bucket.name, filename)
	    bytes_range = 'bytes=%d-%d' % (self.start * RECORD_LENGTH, self.end * RECORD_LENGTH - 1)
	    self.data = obj.get(Range=bytes_range)['Body']
	    
	logger.info("%s [%d, %d) => %s" % (self.path, self.start, self.end, self.proc))
	return self

    def readline(self):
	if self.data_type == self.DATA_S3:
	    return self.data.read(RECORD_LENGTH)
	return self.data.readline()

    def readlines(self):
	start = self.start
	while start < self.end:
	    line = self.readline()
	    start += 1
	    if not line : break
	    yield line

    def close(self):
	self.data.close()


