#!/data/data/com.termux/files/usr/bin/bash

case "$1" in
  start)
    if pgrep -x sshd > /dev/null; then
      echo "SSHD läuft bereits."
    else
      termux-wake-lock
      sshd
      echo "SSHD gestartet (Port 8022)."
    fi
    ;;
  stop)
    pkill sshd
    termux-wake-unlock
    echo "SSHD gestoppt."
    ;;
  restart)
    $0 stop
    sleep 1
    $0 start
    ;;
  status)
    if pgrep -x sshd > /dev/null; then
      echo "SSHD läuft (PID: $(pgrep -x sshd))."
    else
      echo "SSHD läuft nicht."
    fi
    ;;
  *)
    echo "Nutzung: $0 {start|stop|restart|status}"
    exit 1
    ;;
 esac
