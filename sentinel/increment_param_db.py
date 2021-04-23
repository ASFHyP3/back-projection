#!/usr/bin/env python3

import sys
ver=sys.version_info

    


    

import sys, os


# check correct number of inputs
if len(sys.argv)!=5:
    print "Usage: increment_param_db.py database_name <tablename> <parameter> <increment value>"
    sys.exit()

dbname = "/tmp/"+sys.argv[1]  #command line input for database name

# does the file exist?
if not(os.path.exists(dbname)):
    print "ERROR: Database '"+dbname+"' does not exist"
    sys.exit()

# open database
con = sqlite3.connect(dbname)

# create a cursor
c = con.cursor()

ct=sys.argv[2]
param=sys.argv[3]
value=sys.argv[4]

# read in the initial value
currentvalue=sql_mod.valuef(c,ct,param)
newvalue=currentvalue+float(value)
sql_mod.edit_param(c,ct,param,newvalue,'-','-','edited '+' '+param)
# save the changes
con.commit()
# close cursor
c.close()
# close connection
con.close()
sys.exit()
