# SambaFS
Simple Samba file server.

## Quick reference
* Where to file issues:
[GitHub](https://github.com/rardcode/sambafs)

* Supported architectures: amd64 , armv7 , arm64v8

## Installation
```
cd /opt
git clone https://github.com/rardcode/sambafs.git
cd /opt/sambafs
```
Edit `conf/user.list` file with user and share in this format:
```
# user:passwd:perm:share
user1:user1pwd:rw:user1-share
user2:user2pwd:rw:user2-share
```
or pass arg by `-u` option in docker run

## How to run
### With docker run
You can run it with docker run:
```
docker run -d -p 139:139 -p 445:445 \
 -e NETBIOS_NAME=DOMAINNETBIOS \ # optional
 -e SERVER_STRING=DOMAINSTRING \ # optional
 -e WORKGROUP_NAME=DOMAINGROUP \ # optional
 -e SHARE_PUBLIC=Y \ # optional, default is N
 -v "./conf/user.list:/var/samba/conf/user.list" \ # optional is you use "-u" optarg
 -v "/srv/samba:/srv/samba" \
 rardcode/sambafs \
 -u "user1:user1pwd:rw:user1-share" \ # optional if you use user.list file
```
### With docker-compose file
```

services:
  sambafs:
    container_name: sambafs
    image: rardcode/sambafs
    restart: unless-stopped
    ports:
      - 137:137/udp
      - 138:138/udp
      - 139:139
      - 445:445
    environment:
      - SHARE_PUBLIC=N # Y|N
    #  - NETBIOS_NAME=DOMAINNETBIOS
    #  - SERVER_STRING=DOMAINSTRING
    #  - WORKGROUP_NAME=DOMAINGROUP
    volumes:
    - /srv/samba:/srv/samba
    - ./conf/user.list:/var/samba/conf/user.list
    #command: '-u "user1:user1pwd:rw:user1-share"'
```

## Changelog
v1.0.0 - 10.07.2025
- Alpine v. 3.22.0
- samba v. 4.21.4-r4
