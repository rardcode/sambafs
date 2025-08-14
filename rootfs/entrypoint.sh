#!/bin/bash
set -x

[ ! -e /etc/samba/smb.conf-dist ] && mv /etc/samba/smb.conf /etc/samba/smb.conf-dist

echo "
[global]
netbios name  = $NETBIOS_NAME
server string = $SERVER_STRING
workgroup     = $WORKGROUP_NAME
security      = user
map to guest  = bad user"  > /etc/samba/smb.conf

create_share_user () {
echo -e "\n[$share]"
echo "  comment = share per utente $utente"
echo "  path = /srv/samba/$share"
echo "  writeable = yes"
echo "  valid users = $utente"
}

create_share_public () {
echo -e "\n[public]"
echo "  comment = default public share folder"
echo "  path = /srv/samba/public"
echo "  writeable = yes"
echo "  guest ok = yes"
echo "  create mask  = 0666"
echo "  directory mask = 2777"
}

if [ $SHARE_PUBLIC = Y ]; then
mkdir -p /srv/samba/public
chmod 2777 /srv/samba/public
create_share_public >> /etc/samba/smb.conf
fi

TMP_USER_DB=$(mktemp)
cat /var/samba/conf/user.list | grep -Ev '^#|^$' > $TMP_USER_DB

## get user and share passed trought cmdline
while getopts "u:" opt; do
 case $opt in

        u)
        echo $OPTARG >> $TMP_USER_DB
        ;;

 esac
done


cat $TMP_USER_DB | while read LINE; do
    utente=$(echo $LINE | cut -d: -f1)
    pass=$(echo $LINE | cut -d: -f2)
    perm=$(echo $LINE | cut -d: -f3)
    share=$(echo $LINE | cut -d: -f4)

    ## creazione utente unix + pass
    adduser -D $utente
    addgroup $utente
    echo $utente:$pass | chpasswd
    ## creazione utente samba + pass
    echo -e "$pass\n$pass" | smbpasswd -a -s $utente
    smbpasswd -e $utente
    ## creazione share + permessi
    [ ! -e /srv/samba/$share ] && mkdir -p /srv/samba/$share
    chown -R $utente:$utente /srv/samba/$share
    chmod u="$perm"x,g=,o= /srv/samba/$share
    ## aggiunta share in smb.conf
    create_share_user >> /etc/samba/smb.conf
done

setbashrc () {
    echo '
    export PS1="\[\e[01;31m\]\u\[\e[01;32m\]\[\e[00m\]@\[\e[38;5;208m\]\h\[\e[00m\]:\[\e[38;5;111m\]\w\[\e[00m\]\$"
    alias ll="ls -l"
    alias ls="ls --color=auto"
    alias dir="dir --color=auto"
    alias vdir="vdir --color=auto"
    alias grep="grep --color=auto"
    alias fgrep="fgrep --color=auto"
    alias egrep="egrep --color=auto"
    '
}
setbashrc > /etc/profile.d/local.sh

nmbd -D
smbd -F --no-process-group  < /dev/null
