#!/usr/bin/env python

from __future__ import print_function

import boto3
import argparse
import logging
import sys
import ConfigParser
import botocore
import datetime

__all__ = ['RECORD_LENGTH', 'MIN_DATE', 'MAX_DATE', 'BASE_DATE', \
           'fatal', 'error', \
           'get_file_name', 'get_file_size', 'get_file_length', \
           'Options']

RECORD_LENGTH = 80
MIN_DATE = {
    'yellow': datetime.datetime(2009, 1, 1),
    'green' : datetime.datetime(2013, 8, 1)
}
MAX_DATE = {
    'yellow': datetime.datetime(2016, 6, 30),
    'green' : datetime.datetime(2016, 6, 30)
}
BASE_DATE = datetime.datetime(2009, 1, 1)

def fetal(message):
    sys.stderr.write('fetal: %s\n' % message)
    sys.stderr.flush()
    sys.stderr.exit(1)

def error(message):
    sys.stderr.write("error: %s\n" % message)
    sys.stderr.flush()
    sys.stderr.exit(1)

def file_name(color, year, month):
    return "%s-%s%02d.csv" % (color, year, int(month))

def file_size(source, file_name):
    if source.startwith('s3://'):
        s3 = boto3.resource('s3')
	bucket = s3.Bucket(source[5:])
	try:
	    s3.meta.client.head_bucket(Bucket=bucket.name)
	except botocore.exceptions.ClientError as e:
	    error_code = int(e.response['Error']['Code'])
	    if error_code == 404:
		fetal("%s does not existis" % file_name)
    
    return bucket.Object(file_name).content_length

class Options:
    def __init__(self):
	self.parser = argparse.ArgumentParser(
            formatter_class=argparse.ArgumentDefaultsHelpFormatter)
	
	self.parser.add_argument(
            "-c", "--color", type=str, default='yellow', help="color of taxi")

	self.parser.add_argument(
            "-y", "--year", type=int, default=2016, help="year of record")
	
	self.parser.add_argument(
	    "-m", "--month", type=int, default=1, help="month of record")
	
	self.parser.add_argument(
	    "--config", type=str, default='config.ini', help="configuration plan")

	self.parser.add_argument(
	    '--dryrun', default=False, action='store_true', help="dry run")

	self.parser.add_argument(
	    '--debug', action='store_true', default=False, help='debug mode')
	
	class VAction(argparse.Action):
	    def __call__(self, parser, args, values, option_string=None):
		if values is None: value = logging.INFO
		try:
		    values = int(values)
		except ValueError:
		    values = logging.INFO - values.count('v') * 10
		setattr(args, self.dest, values)
	
	self.parser.add_argument(
	    '-v', nargs='?', action=VAction, metavar='vv...', dest='verbose', default=logging.WARNING, help='level of verbose')

    def add(self, *args, **kwargs):
	self.parser.add_argument(*args, **kwargs)

    def load(self):
	self.opts = self.parser.parse_args()
	p = ConfigParser.SafeConfigParser()
	p.read(self.opts.config)
	profile = 'debug' if self.opts.debug else 'default'
	for key, value in p.items(profile):
	    setattr(self.opts, key, value)
	
	return self.opts

    def __str__(self):
	return '\n'.join(['%16s: %s' % (attr, value) for attr, value in self.opts.__dict__.iteritems()])

if __name__ == '__main__':
    o = Options()
    o.load()
    print(o)
