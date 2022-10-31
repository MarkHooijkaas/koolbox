#!/bin/bash

: ${TOOLBOX_USER_DIR:=~/.toolbox}
if [[ -f $TOOLBOX_USER_DIR/init ]]; then
    source $TOOLBOX_USER_DIR/init
fi

# Set user and group info to current user, unless otherwise specified
: ${TOOLBOX_USERNAME:=$(id -un)}
: ${TOOLBOX_UID:=$(id -u)}
: ${TOOLBOX_GROUPNAME:=$(id -gn)}
: ${TOOLBOX_GID:=$(id -g)}

: ${TOOLBOX_IMAGE:=markhooijkaas/koolbox:version-0.0.0}
: ${TOOLBOX_HOME_DIR:=$TOOLBOX_USER_DIR/home}
: ${TOOLBOX_TMP_DIR:=$TOOLBOX_USER_DIR/tmp}

: ${TOOLBOX_CONTAINER_HOME:=/home/$TOOLBOX_USERNAME}
: ${TOOLBOX_MOUNT_ETC_PASSWD:=true}
: ${TOOLBOX_MOUNT_ETC_GROUP:=true}

: ${TOOLBOX_CONTAINER_NAME:=toolbox}

TOOLBOX_MOUNTS="-v $TOOLBOX_HOME_DIR:$TOOLBOX_CONTAINER_HOME"

###############################################################################
# Create and mount /etc/passwd and /etc/group
if $TOOLBOX_MOUNT_ETC_PASSWD;  then
    TOOLBOX_MOUNTS+=" -v $TOOLBOX_TMP_DIR/etc-passwd:/etc/passwd"
    mkdir -p $TOOLBOX_TMP_DIR
    cat <<EOF >$TOOLBOX_TMP_DIR/etc-passwd
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
${TOOLBOX_USERNAME}:x:$TOOLBOX_UID:$TOOLBOX_GID::/home/$TOOLBOX_USERNAME:/bin/bash
EOF
fi

if $TOOLBOX_MOUNT_ETC_GROUP;  then
    TOOLBOX_MOUNTS+=" -v $TOOLBOX_TMP_DIR/etc-group:/etc/group"
    mkdir -p $TOOLBOX_TMP_DIR
    cat <<EOF >$TOOLBOX_TMP_DIR/etc-group
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
${TOOLBOX_GROUPNAME}:x:$TOOLBOX_GID:
EOF

fi;


CMD="docker run --rm --workdir $TOOLBOX_CONTAINER_HOME -it ${TOOLBOX_MOUNTS} ${TOOLBOX_EXTRA_MOUNTS} --name ${TOOLBOX_CONTAINER_NAME} ${TOOLBOX_IMAGE}"
echo $CMD
$CMD
