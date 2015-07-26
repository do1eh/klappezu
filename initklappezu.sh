#!/bin/bash
### BEGIN INIT INFO
#
# Provides: klappezu
# Required-Start: $remote_fs
# Required-Stop: $remote_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: klappezu initscript
#
### END INIT INFO
## Fill in name of program here.
PROG="./klappe.sh"
## Fill in the path to the program here.
PROG_PATH="/home/pi/klappezu/"
 
PIDFILE="/var/run/klappezu.pid"

start() {
      if [ -e $PIDFILE ]; then
          ## Program is running, exit with error.
          echo "Error! $PROG is currently running!" 1>&2
          exit 1
      else
          cd $PROG_PATH
          ## Starts a detached screen session as user pi with title klappezu.
          ## Without 'sudo -u pi', 'screen' will be started as root
          sudo -u pi screen -S klappezu -d -m $PROG > /dev/null 2>&1 &
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

