#!/usr/bin/env python

import ConfigParser

p = ConfigParser.SafeConfigParser()
p.read('config.ini')
for key, value in p.items('default'):
    print(key)
