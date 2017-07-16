#!/usr/bin/env python

from common import *


def parse_argv():
    o = Options()
    o.add('--create_tasks', type=int, dest='create_tasks', metavar='NUM' default=-1, help='create tasks')
    o.add('--receive_tasks', type=int, dest='receive_tasks', metavar='NUM', default=0, help='receive tasks')
    o.add('--delete_after_receive', dest='delete_reveived', action='store_true', default=False, help='delete task after successfully received')
    o.add('--count_tasks', dest='count_tasks', action="store_true", default=False, help='count tasks')
    o.add('--purge_queue', dest='purge_queue', action='store_true', default=False, help='purge queue')
    
    return o.load()

class Task:
    def __init__(self, color, year, month, start, end, timeout=3600, sqs_id=None, sqs_handle=None):
	self.color = color
	self.year = year
	self.month = month
	self.start = start
	self.end = end
	self.timeout = timeout
	self.sqs_id = sqs_id
	self.sqs_handle = sqs_handle
	self.status = None

    def __str__(self):
	return "%(color)s,%(year)d,%(month)d,%(start)d,%(end)d,%(timeout)d" % \
            (self.__dict__)

    def __repr__(self):
	return "%(color)s,%(year)d,%(month)d,%(start)d,%(end)d,%(timeout)d" % \
            (self.__dict__)
    
    def encode(self):
	return self.__str__()

    @classmethod
    def decode(cls, message):
	color, year, month, start, end, timeout = message.body.split(',')
	return Task(color, int(year), int(month), int(start), int(end), int(timeout), message.message_id, message.receipt_handle)

class TaskManager:
    @classmethod
    def cut(clas, start, end, N, nth=None):
	parts = range(start, end + 1, (end -start) / N)
	parts[-1] = end + 1
	if nth is None: return [[parts[i], parts[i+1]] for i in range(N)]
	return [parts[nth], parths[nth + 1]]

    
