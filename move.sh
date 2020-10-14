
#source
ssh-keyscan -H 62.109.17.38 >> ~/.ssh/known_hosts
#or just download shared key
ssh-keygen -q -f id_banana -N ''

#cat /root/support/banaclone/exclude.txt
/dev/
/proc/
/sys/
/boot/
/var/lib/docker/
/var/lib/mysql/
/etc/sysconfig/network-scripts/
/etc/network
/var/www/*/data/tmp/
/var/www/*/data/mod-tmp/
/lib/modules/
/usr/local/mgr5/var/.xmlcache
/var/cache/yum

rsync -avP / --exclude-from /root/support/banaclone/exclude.txt -e 'ssh -i .ssh/id_banana' root@62.109.17.38:/mnt/

rsync -avP /var/lib/mysql/ -e 'ssh -i .ssh/id_banana' root@62.109.17.38:/mnt/var/lib/mysql/
service mysqld stop
rsync -avP /var/lib/mysql/ -e 'ssh -i .ssh/id_banana' root@62.109.17.38:/mnt/var/lib/mysql/
service mysql start
rsync -avP /var/lib/docker/ root@62.109.17.38:/mnt/var/lib/

#final
chroot /mnt/ /bin/bash
mkdir -p /root/support/banaclone/
rsync -avP /etc /root/support/banaclone/
rsync -avP /root --exclude=/root/support/ /root/support/banaclone/
#after resync
yum clean all
yum install kernel
yum reinstall dbus
dracut -f
grub-install /dev/vda
grep -Rils 62.109.8.10 /etc/ | xargs sed -i s'|62.109.8.10|62.109.17.38|g'
grep -Rils 62.109.8.10 /var/named | xargs sed -i s'|62.109.8.10|62.109.17.38|g'
grep -Rils 62.109.8.10 /usr/local/mgr5/etc/ihttpd.conf | xargs sed -i s'|62.109.8.10|62.109.17.38|g'
# чтоб не забыть, так, конечно, не работает))
sqlite3 /usr/local/mgr5/etc/ispmgr.db  -e 'update webdomain_ipaddr set value='62.109.24.79;
reboot

