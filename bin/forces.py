#!/usr/bin/env python3

import sys
import json
from openregister import Item
from openregister.representations.tsv import Writer

fields = ['police-force', 'name', 'start-date', 'end-date']

writer = Writer(sys.stdout, fieldnames=fields)

for row in json.load(sys.stdin):

    force = Item()
    force['police-force'] = row['id']
    force['name'] = row['name']
    writer.write(force)

writer.close()
