#!/usr/bin/env python3
#
#
#  unwrap_parallel.py -- unwrap multiple interferograms in parallel, up to 20 at a time
#
#   note: assume that unwlist, intlist, geolist all exist
#

import os
import subprocess
import sys

if len(sys.argv) <2:
    print ('Usage: unwrap_parallel.py width <filelist=intlist>')
    sys.exit(0)

unwwidth = sys.argv[1]
intfiles='intlist'
if len(sys.argv)>=3:
   intfiles = sys.argv[2]

# unwrap the interferograms, first creating multiple lists of them
command = '$PROC_HOME/util/splitintlist.py '+intfiles  # split igrams into many lists
print (command)
ret = os.system(command)

# how many intlists do you form?
command = 'ls -1 intlist* | cat > listofintlists'  # split igrams into many lists
print (command)
ret = os.system(command)

flist = open('listofintlists','r')
list = flist.readlines()
flist.close()

# unwrap in parallel
num=0
unwcommand=[]
prochome = os.getenv('PROC_HOME')
for intlist in list:
    if intlist.rstrip() != 'intlist':
        if os.path.getsize(intlist.rstrip()) > 0:
            command = prochome+'/util/unwrap_igrams.py '+intlist.rstrip()+' '+unwwidth+' 1'
            print (command)
            #ret = os.system(command)
            unwcommand.append(subprocess.Popen([prochome+'/util/unwrap_igrams.py',intlist.rstrip(),unwwidth,'1']))
            num=num+1

for i in range(num):
    unwcommand[i].wait()

print('Interferograms unwrapped')
