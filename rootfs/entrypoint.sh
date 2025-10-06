#!/bin/bash
set -x

[ ! -d /data ] && mkdir /data

if [ ! -e /data/smb.conf ]; then
echo "
[global]
netbios name  = NETBIOS_NAME
server string = SERVER_STRING
workgroup     = WORKGROUP_NAME
security      = user
map to guest  = bad user

[public]
comment = default public share folder
path = /srv/samba/public
writeable = yes
guest ok = yes
create mask  = 0666
directory mask = 2777" > /data/smb.conf
fi

[ ! -d /srv/samba/public ] && mkdir -p /srv/samba/public && chmod 0777 /srv/samba/public && chown -R nobody:nogroup /srv/samba/public

[ -e /tmp/users.db ] && rm /tmp/users.db

## get user and share passed trought cmdline
while getopts "u:" opt; do
 case $opt in

        u)
        echo $OPTARG >> /tmp/users.db
        ;;

 esac
done

env | grep '^USER' | while read -r value; do
 echo "$value" | cut -d = -f2 >> /tmp/users.db
done

if [ -e /tmp/users.db ]; then
cat /tmp/users.db | while read LINE; do
 utente=$(echo $LINE | cut -d \| -f1)
 pass=$(echo $LINE | cut -d \| -f2)

 # make user unix + pass
 if ! id "$utente" >/dev/null 2>&1; then
  adduser -D "$utente"
  echo "$utente:$pass" | chpasswd
 fi

 # make user samba + pass
 if ! pdbedit -L -u "$utente" >/dev/null 2>&1; then 
  echo -e "$pass\n$pass" | smbpasswd -a -s "$utente"
  smbpasswd -e "$utente"
 fi

done
fi

function custom_bashrc {
echo '
export LS_OPTIONS="--color=auto"
alias "ls=ls $LS_OPTIONS"
alias "ll=ls $LS_OPTIONS -la"
alias "l=ls $LS_OPTIONS -lA"
'
}

function _bashrc {
echo "-----------------------------------------"
echo " .bashrc file setup..."
echo "-----------------------------------------"
custom_bashrc | tee /root/.bashrc
echo 'export PS1="\[\e[35m\][\[\e[31m\]\u\[\e[36m\]@\[\e[32m\]\h\[\e[90m\] \w\[\e[35m\]]\[\e[0m\]# "' >> /root/.bashrc
for i in $(ls /home); do echo 'export PS1="\[\e[35m\][\[\e[33m\]\u\[\e[36m\]@\[\e[32m\]\h\[\e[90m\] \w\[\e[35m\]]\[\e[0m\]$ "' >> /home/${i}/.bashrc; done
}
_bashrc

nmbd -D
smbd -F -d 2 --no-process-group --configfile=/data/smb.conf < /dev/null
