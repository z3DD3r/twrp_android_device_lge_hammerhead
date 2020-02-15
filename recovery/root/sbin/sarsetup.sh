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

F_LOG "Started $0"

# waiting for system
syspath="/dev/block/platform/msm_sdcc.1/by-name/system"
while [ ! -e "$syspath" ]; do
    F_LOG "sleeping a bit as syspath is not there yet.." && sleep 5
done

# mount system
mkdir "/s" >> $LOG 2>&1
mount -t ext4 -o ro "$syspath" "/s" >> $LOG 2>&1 || F_ELOG "mounting /s to $syspath failed"

# detect path to system and vendor for SAR and non-SAR
system_path="/s"
is_sar=$(getprop ro.twrp.sar)
if [ $is_sar == "true" ]; then
  system_path="/s/system"
fi

# copy entire /system/vendor to /vendor. (why not?)
F_LOG "Copying entire /syste/vendor to /vendor ..."
rm -Rf "/vendor" >> $LOG 2>&1
cp -Rf "${system_path}/vendor" "/vendor" >> $LOG 2>&1
cp -Rf "${system_path}/vendor/etc/vintf/manifest.xml" "/vendor/" >> $LOG 2>&1
cp -Rf "${system_path}/vendor/etc/vintf/compatibility_matrix.xml" "/vendor/" >> $LOG 2>&1

# copy additional files to /vendor (1) (just in case if something missed)
F_LOG "Copying additional files from /system/bin to /vendor/bin ..."
mkdir -p "/vendor/bin/hw" >> $LOG 2>&1
cp -Rf "${system_path}/bin/qseecomd" "/vendor/bin/" >> $LOG 2>&1
cp -Rf "${system_path}/bin/hw/android.hardware.keymaster@3.0-service" "/vendor/bin/hw/" >> $LOG 2>&1

# copy additional files to /vendor (2) (just in case if something missed)
F_LOG "Copying additional files from /system/lib to /vendor/lib ..."
mkdir -p "/vendor/lib/hw" >> $LOG 2>&1
cp -Rf "${system_path}/lib/libdiag.so" "/vendor/lib/" >> $LOG 2>&1
cp -Rf "${system_path}/lib/libdrmdiag.so" "/vendor/lib/" >> $LOG 2>&1
cp -Rf "${system_path}/lib/libdrmfs.so" "/vendor/lib/" >> $LOG 2>&1
cp -Rf "${system_path}/lib/libdrmtime.so" "/vendor/lib/" >> $LOG 2>&1
cp -Rf "${system_path}/lib/libkeymaster3device.so" "/vendor/lib/" >> $LOG 2>&1
cp -Rf "${system_path}/lib/liboemcrypto.so" "/vendor/lib/" >> $LOG 2>&1
cp -Rf "${system_path}/lib/libQSEEComAPI.so" "/vendor/lib/" >> $LOG 2>&1
cp -Rf "${system_path}/lib/librpmb.so" "/vendor/lib/" >> $LOG 2>&1
cp -Rf "${system_path}/lib/libssd.so" "/vendor/lib/" >> $LOG 2>&1
cp -Rf "${system_path}/lib/hw/keystore.msm8974.so" "/vendor/lib/hw/" >> $LOG 2>&1
cp -Rf "${system_path}/lib/hw/android.hardware.keymaster@3.0-impl.so" "/vendor/lib/hw/" >> $LOG 2>&1

# copy files from /vendor to /sbin
F_LOG "Copying files from /vendor to /sbin ..."
cp -Rf "/vendor/bin/qseecomd" "/sbin" >> $LOG 2>&1
cp -Rf "/vendor/lib/libdiag.so" "/sbin/" >> $LOG 2>&1
cp -Rf "/vendor/lib/libdrmdiag.so" "/sbin/" >> $LOG 2>&1
cp -Rf "/vendor/lib/libdrmfs.so" "/sbin/" >> $LOG 2>&1
cp -Rf "/vendor/lib/libdrmtime.so" "/sbin/" >> $LOG 2>&1
cp -Rf "/vendor/lib/libkeymaster3device.so" "/sbin/" >> $LOG 2>&1
cp -Rf "/vendor/lib/liboemcrypto.so" "/sbin/" >> $LOG 2>&1
cp -Rf "/vendor/lib/libQSEEComAPI.so" "/sbin/" >> $LOG 2>&1
cp -Rf "/vendor/lib/librpmb.so" "/sbin/" >> $LOG 2>&1
cp -Rf "/vendor/lib/libssd.so" "/sbin/" >> $LOG 2>&1
cp -Rf "/vendor/lib/hw/keystore.msm8974.so" "/sbin/" >> $LOG 2>&1
cp -Rf "/vendor/lib/hw/android.hardware.keymaster@3.0-impl.so" "/sbin/" >> $LOG 2>&1
cp -Rf "/vendor/bin/hw/android.hardware.keymaster@3.0-service" "/sbin/" >> $LOG 2>&1

# relink some binaries in /sbin
relink "/sbin/qseecomd" >> $LOG 2>&1

# unmount system
umount "/s" >> $LOG 2>&1 || F_ELOG "unmounting /s failed"
rm -Rf "/s" >> $LOG 2>&1

# inform that crypto is ready
setprop crypto.ready 1  >> $LOG 2>&1
F_LOG "crypto.ready: $(getprop crypto.ready)"

F_LOG "Ended $0"
exit 0
