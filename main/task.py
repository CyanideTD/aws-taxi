#!/usr/bin/env python

class TaskManager:
    @classmethod
    def cut(clas, start, end, N, nth=None):
	parts = range(start, end + 1, (end -start) / N)
	parts[-1] = end + 1
	if nth is None: return [[parts[i], parts[i+1]]]
