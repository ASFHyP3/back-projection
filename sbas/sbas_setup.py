#!/usr/bin/env python3

#  sbas_setup.py - create auxiliary files for Ann's sbas matlab code

import sys
from datetime import datetime
import os
import math

if len(sys.argv) < 3:
    print ('Usage: sbas_setup.py sbas_list (Peg_point_list.txt or geolist)')
    sys.exit(1)

sbas_list=sys.argv[1]
peg_list=sys.argv[2]

fpeg=open(peg_list,'r')
peg=fpeg.readlines()

slctime=list(float(i) for i in range(0, len(peg)))
deltatime=list(float(i) for i in range(0, len(peg)))
k=0
for line in peg:
    words=line.split()
#    print words[-1]
    slc=words[-1]
    first=slc.find('20')
    slcname=slc[first:first+8]
    slcyear=slcname[0:4]
    slcmon=slcname[4:6]
    slcday=slcname[6:8]
    jd=datetime.strptime(slcname, '%Y%m%d').toordinal()+1721424.5
    slctime[k] = jd #int(slcyear)+float(int(slcmon))/12.+float(int(slcday))/360.
    if k > 0:
        deltatime[k] = slctime[k]-slctime[k-1]
        #deltatime[k] = round((float(slctime[k])-float(slctime[k-1]))*360.)
      #  print k,slctime,deltatime,'\n'
    k=k+1

#print ()
#print ('slctime ',slctime)
#print ('deltime ',deltatime)

ftimedeltas=open('timedeltas.out','w')  # save time intervals between slcs
for i in range(1,len(deltatime)):
    ftimedeltas.write(str(deltatime[i])+'\n')

fsbas=open(sbas_list,'r')
sbas=fsbas.readlines()

fbperp=open('Bperp.out','w')
fdeltime=open('deltime.out','w')
ftm=open('Tm.out','w')

id=0
for line in sbas:
    words=line.split()
    primary=words[0]
    secondary=words[1]
    timebaseline=words[2]
    spacebaseline=words[3]

#  get a short name for primary and secondary files
    first=primary.find('20')
    primaryname=primary[first:first+8]
    primaryyear=primaryname[0:4]
    primarymon=primaryname[4:6]
    primaryday=primaryname[6:8]
    slc1time=datetime.strptime(primaryname, '%Y%m%d').toordinal()+1721424.5

    first=secondary.find('20')
    secondaryname=secondary[first:first+8]
    secondaryyear=secondaryname[0:4]
    secondarymon=secondaryname[4:6]
    secondaryday=secondaryname[6:8]
    slc2time=datetime.strptime(secondaryname, '%Y%m%d').toordinal()+1721424.5

    iprint=0
#    if iprint==1:
#        print primary
#        print primaryname
#        print secondary
#        print secondaryname
#        print timebaseline
#        print spacebaseline
#        print primaryyear+' '+primarymon+' '+primaryday+' '+str(slc1time)+'\n'

    # spatial baseline to Bperp.out
    fbperp.write(spacebaseline+'\n')

    # temporal baseline to deltime.out
    id=id+1
    fdeltime.write(str(id)+' '+timebaseline+' '+str(slc1time)+' '+str(slc2time)+'\n')

    # time interval matrix to Tm.out
    # which slc for primary and secondary?
    k=0
    for line in peg:
        words=line.split()
        slc=words[-1]
        first=slc.find('20')
        slcname=slc[first:first+8]
        if slcname == primaryname:
            kprimary=k
        if slcname == secondaryname:
            ksecondary=k
        k=k+1

    times=list(float(0) for i in range (0,len(peg)))
#    print kprimary,' ',ksecondary
    if kprimary < ksecondary:
        for i in range(kprimary,ksecondary):
            times[i]=deltatime[i+1]
    if kprimary > ksecondary:
        for i in range(ksecondary,kprimary):
            times[i]=-deltatime[i+1]
    for i in range(0,len(times)-1):
        ftm.write(str(times[i])+' ')
    ftm.write('\n')

sys.exit()

