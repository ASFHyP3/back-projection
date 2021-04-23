#!/usr/bin/env python3

#  new_intlist - update intlist for new sbas_list with different baseline limits

import string
import os
import sys

if len(sys.argv) < 1:
    print ('Usage: new_intlist.py sbas_list')
    sys.exit(1)

sbaslist=sys.argv[1]

# sbaslist

fintlist=open('intlist','w')

sbasfiles=[]
fsbas=open(sbaslist,'r')
sbas=fsbas.readlines()
for line in sbas:
    words=line.split()
    file1=words[0]
    file2=words[1]
#  get a short names for file1 and file2 files
    first=file1.find('20')
    file1name=file1[first:first+8]
    first=file2.find('20')
    file2name=file2[first:first+8]

#    print 'file1 file2'
#    print file1
#    print file2

    intfile=file1name+'_'+file2name+'.int'

    fintlist.write(intfile)
    fintlist.write('\n')

fintlist.close()
fsbas.close()

sys.exit()
