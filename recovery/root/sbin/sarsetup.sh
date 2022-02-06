#!/sbin/sh
#
# Made for Hammerhead
#

LOG=/tmp/recovery.log
TAG=PREPARE

F_LOG()
{
   MSG="$1"
   echo -e "I:$TAG: $(date +%F_%T) - $MSG" >> $LOG
}

F_ELOG()
{
   MSG="$1"
   echo -e "E:$TAG: $(date +%F_%T) - $MSG" >> $LOG
}

relink()
{
    sed -i 's|/system/bin/linker|///////sbin/linker|' "$1"
    chmod 755 "$1"
}

setprop crypto.ready 1  >> $LOG 2>&1
exit 0
