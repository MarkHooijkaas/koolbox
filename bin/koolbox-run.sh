#!/bin/bash

: ${KOOLBOX_USER_DIR:=~/.toolbox}
if [[ -f $KOOLBOX_USER_DIR/init ]]; then
    source $KOOLBOX_USER_DIR/init
fi

# Set user and group info to current user, unless otherwise specified
: ${KOOLBOX_USERNAME:=$(id -un)}
: ${KOOLBOX_UID:=$(id -u)}
: ${KOOLBOX_GROUPNAME:=$(id -gn)}
: ${KOOLBOX_GID:=$(id -g)}

: ${KOOLBOX_IMAGE:=koolbox:latest}
: ${KOOLBOX_HOME_DIR:=$KOOLBOX_USER_DIR/home}
: ${KOOLBOX_TMP_DIR:=$KOOLBOX_USER_DIR/tmp}

: ${KOOLBOX_CONTAINER_HOME:=/home/$KOOLBOX_USERNAME}
: ${KOOLBOX_MOUNT_ETC_PASSWD:=true}
: ${KOOLBOX_MOUNT_ETC_GROUP:=true}

: ${KOOLBOX_CONTAINER_NAME:=toolbox}

KOOLBOX_MOUNTS="-v $KOOLBOX_HOME_DIR:$KOOLBOX_CONTAINER_HOME"

###############################################################################
# Create and mount /etc/passwd and /etc/group
if $KOOLBOX_MOUNT_ETC_PASSWD;  then
    KOOLBOX_MOUNTS+=" -v $KOOLBOX_TMP_DIR/etc-passwd:/etc/passwd"
    mkdir -p $KOOLBOX_TMP_DIR
    cat <<EOF >$KOOLBOX_TMP_DIR/etc-passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
_apt:x:100:65534::/nonexistent:/usr/sbin/nologin
${KOOLBOX_USERNAME}:x:$KOOLBOX_UID:$KOOLBOX_GID::/home/$KOOLBOX_USERNAME:/bin/bash
EOF
fi

if $KOOLBOX_MOUNT_ETC_GROUP;  then
    KOOLBOX_MOUNTS+=" -v $KOOLBOX_TMP_DIR/etc-group:/etc/group"
    mkdir -p $KOOLBOX_TMP_DIR
    cat <<EOF >$KOOLBOX_TMP_DIR/etc-group
root:x:0:
daemon:x:1:
bin:x:2:
sys:x:3:
adm:x:4:
tty:x:5:
disk:x:6:
lp:x:7:
mail:x:8:
news:x:9:
uucp:x:10:
man:x:12:
proxy:x:13:
kmem:x:15:
dialout:x:20:
fax:x:21:
voice:x:22:
cdrom:x:24:
floppy:x:25:
tape:x:26:
sudo:x:27:
audio:x:29:
dip:x:30:
www-data:x:33:
backup:x:34:
operator:x:37:
list:x:38:
irc:x:39:
src:x:40:
gnats:x:41:
shadow:x:42:
utmp:x:43:
video:x:44:
sasl:x:45:
plugdev:x:46:
staff:x:50:
games:x:60:
users:x:100:
nogroup:x:65534:
${KOOLBOX_GROUPNAME}:x:$KOOLBOX_GID:
EOF

fi;


CMD="docker run --rm --workdir $KOOLBOX_CONTAINER_HOME -it ${KOOLBOX_MOUNTS} ${KOOLBOX_EXTRA_MOUNTS} --name ${KOOLBOX_CONTAINER_NAME} ${KOOLBOX_IMAGE}"
echo $CMD
$CMD
