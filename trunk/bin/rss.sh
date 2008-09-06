#!/bin/sh
/home/mbsd/bin/rss2htmlsum.pl http://www.justjournal.com/users/mbsd/rss /home/mbsd/docs/mbsdblogsum.inc
/home/mbsd/bin/rss2html.pl http://www.justjournal.com/users/mbsd/rss  /home/mbsd/docs/mbsdblog.inc
/home/mbsd/bin/rss2htmlsum.pl http://cia.vc/stats/project/midnightbsd/.rss /home/mbsd/docs/cvslistsum.inc
/home/mbsd/bin/rss2html.pl http://cia.vc/stats/project/midnightbsd/.rss /home/mbsd/docs/cvslist.inc
