#!/usr/bin/bash

/usr/bin/kill -9 `/usr/bin/cat /var/spool/echoserver/master.pid`

/usr/bin/rm -f /var/spool/echoserver/master.pid
