#/bin/sh
umount -R /mnt
# самый жирный раздел
disk=$(lsblk -lps -x FSSIZE | awk '{print $1}' | sed -n '2p'| head -1)
echo $disk
mount $disk /mnt
mount /dev --bind /mnt/dev
mount /proc --bind /mnt/proc
mount /sys  --bind /mnt/sys
#находим пипишник
if [ -f /mnt/etc/sysconfig/network-scripts/ifcfg-eth0 ] 
then
	address=$(cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep IPADDR | awk -F '"' '{print $2}' | head -1)
else
	address=$(cat /mnt/etc/network/interfaces | grep address | awk -F ' ' '{print $2}')
fi
echo $address
#узнаем имя интерфейса
iface=$(ifconfig | grep  "ens3\|eth0" | cut -c -4)
echo $iface
# Прожимаем сеть
systemctl stop NetworkManager
ifconfig $iface $address netmask 255.255.255.255
route add 10.0.0.1 $iface
route add default gw 10.0.0.1 $iface
iptables -F
iptables -P INPUT ACCEPT
ping -c 2 8.8.8.8
#enable eGO-GO
