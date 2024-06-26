#!/usr/bin/env python3
#
#  create a dem using the copernicus 30m archive on amazon
#
#  modified 19feb21 to allow for retrieving files from pangea server instead of aws

import sys
import os
import string

AWS=0  #  set this to 1 if you want to feth dewm from AWS, 0 for pangea.stanford.edu
pangea=1-AWS

if len(sys.argv)< 2:
    print ('Usage: cop_dem.py botlat leftlon')
    sys.exit(1)

botlat=int(sys.argv[1])
leftlon=int(sys.argv[2])
#print ('input botlat leftlon ',botlat,leftlon)

# change +/- to NS EW
if botlat<0:
    ns='S'
    if botlat < -9:
        botlatstr=ns+str(-botlat)
    else:
        botlatstr=ns+'0'+str(-botlat)
else:
    ns='N'
    if(botlat > 9):
        botlatstr=ns+str(botlat)
    else:
        botlatstr=ns+'0'+str(botlat)

if leftlon<0:
    ew='W'
    if leftlon < -99:
        leftlonstr=ew+str(-leftlon)
    else:
        leftlonstr=ew+'00'+str(-leftlon)
else:
    ew='E'
    if(leftlon > 99):
        leftlonstr=ew+str(leftlon)
    else:
        leftlonstr=ew+'00'+str(leftlon)

if len(leftlonstr) > 4:
    leftlonstr=leftlonstr.replace('00','0')

#print ('botlat, leftlon: ',botlat,leftlon)
#print ('botlatstr, leftlonstr ',botlatstr,leftlonstr)
#sys.exit(1)

demfile='Copernicus_DSM_COG_10_xlat_00_xlon_00_DEM.tif'
demfile=demfile.replace('xlat',botlatstr).replace('xlon',leftlonstr)
# save dem list to demfiles.txt
fdem=open('demfiles.txt','a')
fdem.write(demfile.replace('.tif','.dem'))
fdem.write('\n')
fdem.close()

# retreive from either aws or pangea

if AWS == 1:
    # download tile from aws if we don't already have it
    if not os.path.exists(demfile):
        command = 'aws s3 cp s3://copernicus-dem-30m/'+demfile.replace('.tif','')+'/'+demfile+' . --no-sign-request'
        #print (command)
        ret=os.system(command)
        
        command = 'coptiffread 2>/dev/null '+demfile+' '+demfile.replace('.tif','.dem')
        #print (command)
        ret=os.system(command)

if pangea == 1:
    # download tile from pangea if we don't already have it
    dem=demfile.replace('.tif','.dem')
    rsc=demfile.replace('.tif','.dem.rsc')
    if not os.path.exists(rsc):
        address='http://pangea.stanford.edu/sesfs/copernicus/'+rsc
        command = 'wget -qN '+address
#        print (' wget command: ',command)
        ret=os.system(command)
        if ret == 0:
            print ('retrieved ',rsc)
    if not os.path.exists(dem):
        address='http://pangea.stanford.edu/sesfs/copernicus/'+dem
        command = 'wget -qN '+address
#        print (' wget command: ',command)
        ret=os.system(command)
        if ret == 0:
            print ('retrieved ',dem)
