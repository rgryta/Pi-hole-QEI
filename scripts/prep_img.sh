#!/bin/bash
SCRIPT_PATH=$(dirname $(realpath -s $0))
rm $SCRIPT_PATH/../Image.img

URL=`curl https://www.raspberrypi.com/software/operating-systems/ | grep -Eo 'https:\/\/downloads\.raspberrypi\.org\/raspios_lite_armhf\/images\/[a-zA-Z0-9\/\._\-]+\.xz' | head -1`
curl $URL --output "$SCRIPT_PATH/image.img.xz"
xz -T0 -d -k -v "$SCRIPT_PATH/image.img.xz"

mkdir -p "$SCRIPT_PATH/mountpoint"

INFO=`file "$SCRIPT_PATH/image.img" | grep -Eo 'startsector [0-9]+'`

SECTOR=`echo $INFO | awk '{ print $4 }'`
sudo mount "$SCRIPT_PATH/image.img" -o offset=$[512*$SECTOR] "$SCRIPT_PATH/mountpoint"

sudo sh -c "cp -r ""$SCRIPT_PATH/conf"" ""$SCRIPT_PATH/mountpoint"""

sudo umount "$SCRIPT_PATH/mountpoint"

# Prepare boot partition (enable SSH)

SECTOR=`echo $INFO | awk '{ print $2 }'`
sudo mount "$SCRIPT_PATH/image.img" -o offset=$[512*$SECTOR] "$SCRIPT_PATH/mountpoint"

sudo touch "$SCRIPT_PATH/mountpoint/ssh"
sudo touch "$SCRIPT_PATH/mountpoint/userconf" 

PI_USER=`cat "$SCRIPT_PATH/../prep_img_args" | grep 'PIHOLE_USER=' | awk -F= '{ print $2 }' | tr -d '"'`
PI_PASS=`cat "$SCRIPT_PATH/../prep_img_args" | grep 'PIHOLE_PASS=' | awk -F= '{ print $2 }' | tr -d '"'`

sudo echo "$PI_USER:`echo ""$PI_PASS"" | openssl passwd -6 -stdin`" > "$SCRIPT_PATH/mountpoint/userconf" 

sudo touch "$SCRIPT_PATH/mountpoint/firstrun.sh"
sudo cat "$SCRIPT_PATH/initscript/1-header" >> "$SCRIPT_PATH/mountpoint/firstrun.sh"

while IFS="" read -r line || [ -n "$line" ]
do
  output="$(printf '%s\n' "$line")"
  if [[ -n $output ]]
  then
    printf '%s\n' "export $line" >> "$SCRIPT_PATH/mountpoint/firstrun.sh"
  fi
done < "$SCRIPT_PATH/../prep_img_args"
echo "" >> "$SCRIPT_PATH/mountpoint/firstrun.sh"

sudo cat "$SCRIPT_PATH/initscript/2-vars" >> "$SCRIPT_PATH/mountpoint/firstrun.sh"
sudo cat "$SCRIPT_PATH/initscript/3-keyboard" >> "$SCRIPT_PATH/mountpoint/firstrun.sh"
sudo cat "$SCRIPT_PATH/initscript/4-host" >> "$SCRIPT_PATH/mountpoint/firstrun.sh"
sudo cat "$SCRIPT_PATH/initscript/5-lan" >> "$SCRIPT_PATH/mountpoint/firstrun.sh"
sudo cat "$SCRIPT_PATH/initscript/6-upgrade" >> "$SCRIPT_PATH/mountpoint/firstrun.sh"
sudo cat "$SCRIPT_PATH/initscript/7-pi-hole" >> "$SCRIPT_PATH/mountpoint/firstrun.sh"
sudo cat "$SCRIPT_PATH/initscript/8-unbound" >> "$SCRIPT_PATH/mountpoint/firstrun.sh"
sudo cat "$SCRIPT_PATH/initscript/9-footer" >> "$SCRIPT_PATH/mountpoint/firstrun.sh"

STARTUP="systemd.run=/boot/firstrun.sh systemd.run_success_action=reboot systemd.unit=kernel-command-line.target"
echo "`head -1 ""$SCRIPT_PATH/mountpoint/cmdline.txt""` `echo -n ""$STARTUP""`" > "$SCRIPT_PATH/mountpoint/cmdline.txt"

sudo umount "$SCRIPT_PATH/mountpoint"

mv $SCRIPT_PATH/Image.img $SCRIPT_PATH/../Image.img
rm $SCRIPT_PATH/image.img.xz
rm -rf "$SCRIPT_PATH/mountpoint"