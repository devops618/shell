disk_list="/dev/vdb
/dev/vdc
/dev/vdd"
flag=0

chattr -i /etc/fstab

for disk in $(echo ${disk_list})
do

parted ${disk} <<EOF
mklabel gpt
mkpart primary 2048s 100%
quit
EOF


sleep 3
/usr/sbin/mkfs -t xfs ${disk}1 && echo "mkfs success"
if [[ $flag != 0 ]];then
mkdir /data${flag}
fi

uuid=$(blkid ${disk}1 |awk '{print $2}')
if [[ $flag = 0 ]];then
  echo "${uuid}    /data    xfs    defaults    0 0" >> /etc/fstab
else
  echo "${uuid}    /data${flag}    xfs    defaults    0 0" >> /etc/fstab
fi

flag=$(expr ${flag} + 1)

done

mount -a
chattr +i /etc/fstab
