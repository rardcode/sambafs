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
Launch docker the first time: a simple smb.conf will be created in data/ dir.\
Docker is ready for a public samba share in /srv/samba/public.\
Edit data/smb.conf with your desidered shares and compose.yml with user to add (you can pass user with `-u` option in docker run).


## How to run
### With docker run
You can run it with docker run:
```
docker run -d -p 139:139 -p 445:445 \
 -e USER1=username|password \ # optional
 -v "/srv/samba:/srv/samba" \
 -v "./data:/data" \
 rardcode/sambafs \
 -u user1:user1pwd \ # optional if you use user.list file
```
### With docker-compose file
```
services:
  sambafs:
    image: rardcode/sambafs
    container_name: sambafs
    restart: unless-stopped
    ports:
      - 137:137/udp
      - 138:138/udp
      - 139:139
      - 445:445
    #environment:
    #  - USER1=user|pass
    volumes:
    #- /srv/samba:/srv/samba
    - ./data:/data
    #command: '-u user1:user1pwd'
```

## Changelog
v.2.0.0 - 06.10.2025
- Significant build logic rewrite

v.1.0.1 - 14.08.2025
- Alpine v. 3.22.1
- samba v. 4.21.4-r4

v.1.0.0 - 10.07.2025
- Alpine v. 3.22.0
- samba v. 4.21.4-r4
