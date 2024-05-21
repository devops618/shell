flag=1
disk_list="/dev/vdd"

for disk in $(echo ${disk_list}); do
  echo "n
p
1


w
" | fdisk ${disk}
  mkfs -t xfs ${disk}1
  dir=/data${flag}
  mkdir ${dir}
  echo "${disk}1       ${dir}   xfs     defaults        0 0" >>/etc/fstab
  flag=$(expr ${flag} + 1)
done

mount -a
df -h
