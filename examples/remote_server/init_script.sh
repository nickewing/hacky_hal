#! /bin/sh
### BEGIN INIT INFO
# Provides:          remote_server
# Required-Start:
# Required-Stop:
# Should-Start:
# Default-Start:
# Default-Stop:
# Short-Description: Run AV remote server
# Description:       Run AV remove server
### END INIT INFO

port=4567
pid_file=/home/pi/remote_server.pid
log_file=/home/pi/remote_server.log

server_dir=/home/pi/HackyHAL/examples/remote_server/
server_script=server.rb

start () {
  cd $server_dir && sudo -u pi thin --daemonize --port $port --pid $pid_file --log $log_file start
}

stop () {
  cd $server_dir && sudo -u pi thin --pid $pid_file stop
}

case "$1" in
  "")
    echo "Warning: remote_server.sh should be called with the 'start' argument." >&2
    start
    ;;
  start)
    start
    ;;
  restart|reload|force-reload)
    stop
    start
    ;;
  stop)
    stop
    ;;
  *)
    echo "Usage: remote_server.sh [start|stop|restart]" >&2
    exit 3
    ;;
esac
