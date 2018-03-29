#!/usr/bin/bash

/usr/bin/kill -9 `/usr/bin/cat /var/spool/dumbstack/master.pid`

/usr/bin/rm -f /var/spool/dumbstack/master.pid
