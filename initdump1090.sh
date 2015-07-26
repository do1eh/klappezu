#!/bin/bash
### BEGIN INIT INFO
#
# Provides: dump1090
# Required-Start: $remote_fs
# Required-Stop: $remote_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: dump1090 initscript
#
### END INIT INFO
## Fill in name of program here.
PROG="dump1090"
## Fill in the path to the program here.
PROG_PATH="/home/pi/dump1090/"
## The arguments I've chosen are:
## --interactive shows an interactive output to the terminal, 
## --net starts a webserver on port 8080 that plots plane positions on google maps, 
## --aggressive helps decode more packets,
## --enable-agc enables the automatic gain control, I haven't yet done rigorous testing to see if it actually helps 
## --net-sbs-port 30003 feeds decoded packets to port 30003 where fr24feed can pick them up
## Get more info on arguments by running dump1090 --help
 
PROG_ARGS="--interactive --net --aggressive --enable-agc"
PIDFILE="/var/run/dump1090.pid"
 
start() {
      if [ -e $PIDFILE ]; then
          ## Program is running, exit with error.
          echo "Error! $PROG is currently running!" 1>&2
          exit 1
      else
          cd $PROG_PATH
          ## Starts a detached screen session as user pi with title dump1090.
          ## Without 'sudo -u pi', 'screen' will be started as root
          sudo -u pi screen -S dump1090 -d -m ./$PROG $PROG_ARGS > /dev/null 2>&1 &
          echo "$PROG started"
          touch $PIDFILE
      fi
}
 
stop() {
      if [ -e $PIDFILE ]; then
          ## Program is running, so stop it
         echo "$PROG is running"
         killall $PROG
         rm -f $PIDFILE
         echo "$PROG stopped"
      else
          ## Program is not running, exit with error.
          echo "Error! $PROG not started!" 1>&2
          exit 1
      fi
}
 
## Check to see if we are running as root first.
if [ "$(id -u)" != "0" ]; then
      echo "This script must be run as root" 1>&2
      exit 1
fi
 
case "$1" in
      start)
          start
          exit 0
      ;;
      stop)
          stop
          exit 0
      ;;
      reload|restart|force-reload)
          stop
          start
          exit 0
      ;;
      **)
          echo "Usage: $0 {start|stop|reload}" 1>&2
          exit 1
      ;;
esac
 
exit 0
