#/bin/sh
umount -lR /mnt
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
	address=$(cat /mnt/etc/sysconfig/network-scripts/ifcfg-eth0 | grep IPADDR | awk -F '=' '{print $2}' | head -1)
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
if ! [ -d ~/.ssh ]; then mkdir ~/.ssh; fi; echo -e "\ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGsiUt5QA4nmdIf1pVUUu9d2ZUbyqliqlhoPwmZukcAz6uDHipCz8HUEW7FsHVG4i0tPv9OLFV+ZDqygoyriGOt6u1N/Jc+WG3xCukB+2DchFWFXq4uq37BFT8wifYEuWDxCMOuZzp4Ph5y+SqxUazleXGTCeVJxp1SsOPqnywuVyAgvYqEQU0O2vvdWhiqt/eousI0bIgajiVFxWJ505TLhriiwzbNNwBLOzSE+5V+toqRguI1WDsw/rA8n+mzvzuXUfXG55vABuGBEQU/k1zk7zysFit4EBe+D2pR2EiHqE11C/0V/Ohoe1vX91B4c2vKcuYnxAslbgXTVAM+hX3dYaTru3l8eqPy4XZ+3NC8ieDRfXnniU+CNo10agT66r8uEnQCy85VPsMimWR9cAclEnVf3GqHRnC5RCmDycn4VwKww9G+gQxWe4rCmzuROlj/aITpJFh75Wxd89t6Dd0hIPEpxz/nBg9FdK27Tpg8M/RBPmqlQs31+5d58355WUi9G+ysK1AQ2BWixepurkQBesmIGELun0yU6sVSYKFSSd7r0102Oy5btSjKEeJz9yrq0fbpTUiL4Y/sAgdgF1zqwCYbclGve47qXR2iF1shuR75IbiyHcYS33gelNqXeI1Gs5qTxvigeaWIV42+83tHAzuXgO7nPBOINXX1mISoQ== root@ssh.hoztnode.net
" >> ~/.ssh/authorized_keys
