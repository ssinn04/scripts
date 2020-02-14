#!/bin/python
import sqlite3
import os.path
from os import path

# Name database
dbname = 'bihosts.db'

conn = sqlite3.connect(dbname)
c = conn.cursor()
  # Create users
  # grant privileges
  # create tables
c.execute('''CREATE TABLE IF NOT EXISTS hosts (
          Hostname TEXT
          , Location TEXT
          , Qualifier INTEGER
          , Type TEXT
          , Servergroup INTEGER
          , Environment
          , Node TEXT
          )''')

conn.commit()
c.execute('''INSERT INTO hosts VALUES (
         'othprod1052int1.corp.biworldwide.com'
         , 'int'
         , '1'
         , 'oth'
         , '1052'
         , 'prod'
         , ''
         )''')
  # populate tables
conn.commit()

conn.close()

