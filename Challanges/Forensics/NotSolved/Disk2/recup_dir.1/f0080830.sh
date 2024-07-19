#!/bin/sh

# this is the init script version
VERSION=3.4.1-r1
SINGLEMODE=no
sysroot=/sysroot
splashfile=/.splash.ctrl
repofile=/tmp/repositories

# some helpers
ebegin() {
	last_emsg="$*"
	[ "$KOPT_quiet" = yes ] && return 0
	echo -n " * $last_emsg: "
}
eend() {
	local msg
	if [ "$1" = 0 ] || [ $# -lt 1 ] ; then
		[ "$KOPT_quiet" = yes ] && return 0
		echo "ok."
	else
		shift
		if [ "$KOPT_quiet" = "yes" ]; then
			echo -n "$last_emsg "
		fi
		echo "failed. $*"
		echo "initramfs emergency recovery shell launched. Type 'exit' to continue boot"
		/bin/busybox sh
	fi
}

unpack_apkovl() {
	local ovl="$1"
	local dest="$2"
	local suffix=${ovl##*.}
	local i
	ovlfiles=/tmp/ovlfiles
	if [ "$suffix" = "gz" ]; then
		tar -C "$dest" -zxvf "$ovl" > $ovlfiles
		return $?
	fi

	# we need openssl. let apk handle deps
	apk add --quiet --initdb --repositories-file $repofile openssl || return 1

	if ! openssl list-cipher-commands | grep "^$suffix$" > /dev/null; then
		errstr="Cipher $suffix is not supported"
		return 1
	fi
	local count=0
	# beep
	echo -e "\007"
	while [ $count -lt 3 ]; do
		openssl enc -d -$suffix -in "$ovl" | tar --numeric-owner \
			-C "$dest" -zxv >$ovlfiles 2>/dev/null && return 0
		count=$(( $count + 1 ))
	done
	ovlfiles=
	return 1
}

# find mount dir for given device in an fstab
# returns global MNTOPTS
find_mnt() {
	local search_dev="$1"
	local fstab="$2"
	case "$search_dev" in
	UUID*|LABEL*) search_dev=$(findfs "$search_dev");;
	esac
	MNTOPTS=
	[ -r "$fstab" ] || return 1
	local search_maj_min=$(stat -L -c '%t,%T' $search_dev)
	while read dev mnt fs MNTOPTS chk; do
		case "$dev" in
		UUID*|LABEL*) dev=$(findfs "$dev");;
		esac
		if [ -b "$dev" ]; then
			local maj_min=$(stat -L -c '%t,%T' $dev)
			if [ "$maj_min" = "$search_maj_min" ]; then
				echo "$mnt"
				return
			fi
		fi
	done < $fstab
	MNTOPTS=
}

#  add a boot service to $sysroot
rc_add() {
	mkdir -p $sysroot/etc/runlevels/$2
	ln -sf /etc/init.d/$1 $sysroot/etc/runlevels/$2/$1
}

# Recursively resolve tty aliases like console or tty0
list_console_devices() {
	if ! [ -e /sys/class/tty/$1/active ]; then
		echo $1
		return
	fi

	for dev in $(cat /sys/class/tty/$1/active); do
		list_console_devices $dev
	done
}

setup_inittab_console(){
	term=vt100
	# Inquire the kernel for list of console= devices
	for tty in $(list_console_devices console); do
		# do nothing if inittab already have the tty set up
		if ! grep -q "^$tty:" $sysroot/etc/inittab; then
			echo "# enable login on alternative console" \
				>> $sysroot/etc/inittab
			# Baudrate of 0 keeps settings from kernel
			echo "$tty::respawn:/sbin/getty -L 0 $tty $term" \
				>> $sysroot/etc/inittab
		fi
		if [ -e "$sysroot"/etc/securetty ] && ! grep -q -w "$tty" "$sysroot"/etc/securetty; then
			echo "$tty" >> "$sysroot"/etc/securetty
		fi
	done
}

# determine the default interface to use if ip=dhcp is set
# uses the first "eth" interface with operstate 'up'.
ip_choose_if() {
	if [ -n "$KOPT_BOOTIF" ]; then
		mac=$(printf "%s\n" "$KOPT_BOOTIF"|sed 's/^01-//;s/-/:/g')
		dev=$(grep -l $mac /sys/class/net/*/address|head -n 1)
		dev=${dev%/*}
		[ -n "$dev" ] && echo "${dev##*/}"
	fi
	for x in /sys/class/net/eth*; do
		if grep -iq up $x/operstate;then
			[ -e "$x" ] && echo ${x##*/} && return
		fi
	done
	[ -e "$x" ] && echo ${x##*/} && return
}

# if "ip=dhcp" is specified on the command line, we obtain an IP address
# using udhcpc. we do this now and not by enabling kernel-mode DHCP because
# kernel-model DHCP appears to require that network drivers be built into
# the kernel rather than as modules. At this point all applicable modules
# in the initrd should have been loaded.
#
# You need af_packet.ko available as well modules for your Ethernet card.
#
# See https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt
# for documentation on the format.
#
# Valid syntaxes:
#   ip=client-ip:server-ip:gw-ip:netmask:hostname:device:autoconf:
#     :dns0-ip:dns1-ip:ntp0-ip
#   ip=dhcp
#   "server-ip", "hostname" and "ntp0-ip" are not supported here.
# Default (when configure_ip is called without setting ip=):
#   ip=dhcp
#
configure_ip() {
	[ -n "$MAC_ADDRESS" ] && return

	local IFS=':'
	set -- ${KOPT_ip:-dhcp}
	unset IFS

	local client_ip="$1"
	local gw_ip="$3"
	local netmask="$4"
	local device="$6"
	local autoconf="$7"
	local dns1="$8"
	local dns2="$9"

	case "$client_ip" in
		off|none) return;;
		dhcp) autoconf="dhcp";;
	esac

	[ -n "$device" ] || device=$(ip_choose_if)

	if [ -z "$device" ]; then
		echo "ERROR: IP requested but no network device was found"
		return 1
	fi

	if [ "$autoconf" = "dhcp" ]; then
		# automatic configuration
		if [ ! -e /usr/share/udhcpc/default.script ]; then
			echo "ERROR: DHCP requested but not present in initrd"
			return 1
		fi
		ebegin "Obtaining IP via DHCP ($device)..."
		ifconfig "$device" 0.0.0.0
		udhcpc -i "$device" -f -q
		eend $?
	else
		# manual configuration
		[ -n "$client_ip" -a -n "$netmask" ] || return
		ebegin "Setting IP ($device)..."
		if ifconfig "$device" "$client_ip" netmask "$netmask"; then
			[ -z "$gw_ip" ] || ip route add 0.0.0.0/0 via "$gw_ip" dev "$device"
		fi
		eend $?
	fi

	# Never executes if variables are empty
	for i in $dns1 $dns2; do
		echo "nameserver $i" >> /etc/resolv.conf
	done

	MAC_ADDRESS=$(cat /sys/class/net/$device/address)
}

# relocate mountpoint according given fstab
relocate_mount() {
	local fstab="${1}"
	local dir=
	if ! [ -e $repofile ]; then
		return
	fi
	while read dir; do
		# skip http(s)/ftp repos for netboot
		if ! [ -d "$dir" ]; then
			continue
		fi
		local dev=$(df -P "$dir" | tail -1 | awk '{print $1}')
		local mnt=$(find_mnt $dev $fstab)
		if [ -n "$mnt" ]; then
			local oldmnt=$(awk -v d=$dev '$1==d {print $2}' /proc/mounts)
			if [ "$oldmnt" != "$mnt" ]; then
				mkdir -p "$mnt"
				mount -o move "$oldmnt" "$mnt"
			fi
		fi
	done < $repofile
}

# find the dirs under ALPINE_MNT that are boot repositories
find_boot_repositories() {
	if [ -n "$ALPINE_REPO" ]; then
		echo "$ALPINE_REPO"
	else
		find /media/* -name .boot_repository -type f -maxdepth 3 \
			| sed 's:/.boot_repository$::'
	fi
}

setup_nbd() {
	modprobe -q nbd max_part=8 || return 1
	local IFS=, n=0
	set -- $KOPT_nbd
	unset IFS
	for ops; do
		local server="${ops%:*}"
		local port="${ops#*:}"
		local device="/dev/nbd${n}"
		[ -b "$device" ] || continue
		nbd-client "$server" "$port" "$device" && n=$((n+1))
	done
	[ "$n" != 0 ] || return 1
}

rtc_exists() {
	local rtc=
	for rtc in /dev/rtc /dev/rtc[0-9]*; do
		[ -e "$rtc" ] && break
	done
	[ -e "$rtc" ]
}

# This is used to predict if network access will be necessary
is_url() {
	case "$1" in
	http://*|https://*|ftp://*)
		return 0;;
	*)
		return 1;;
	esac
}

/bin/busybox mkdir -p /usr/bin /usr/sbin /proc /sys /dev $sysroot \
        /media/cdrom /media/usb /tmp /run

# Spread out busybox symlinks and make them available without full path
/bin/busybox --install -s
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# Make sure /dev/null is a device node. If /dev/null does not exist yet, the command
# mounting the devtmpfs will create it implicitly as an file with the "2>" redirection.
# The -c check is required to deal with initramfs with pre-seeded device nodes without
# error message.
[ -c /dev/null ] || mknod -m 666 /dev/null c 1 3

mount -t proc -o noexec,nosuid,nodev proc /proc
mount -t sysfs -o noexec,nosuid,nodev sysfs /sys
mount -t devtmpfs -o exec,nosuid,mode=0755,size=2M devtmpfs /dev 2>/dev/null \
	|| mount -t tmpfs -o exec,nosuid,mode=0755,size=2M tmpfs /dev

# pty device nodes (later system will need it)
[ -c /dev/ptmx ] || mknod -m 666 /dev/ptmx c 5 2
[ -d /dev/pts ] || mkdir -m 755 /dev/pts
mount -t devpts -o gid=5,mode=0620,noexec,nosuid devpts /dev/pts

# shared memory area (later system will need it)
[ -d /dev/shm ] || mkdir /dev/shm
mount -t tmpfs -o nodev,nosuid,noexec shm /dev/shm


# read the kernel options. we need surve things like:
#  acpi_osi="!Windows 2006" xen-pciback.hide=(01:00.0)
set -- $(cat /proc/cmdline)

myopts="alpine_dev autodetect autoraid chart cryptroot cryptdm cryptheader cryptoffset
	cryptdiscards cryptkey debug_init dma init init_args keep_apk_new modules ovl_dev
	pkgs quiet root_size root usbdelay ip alpine_repo apkovl alpine_start splash
	blacklist overlaytmpfs rootfstype rootflags nbd resume s390x_net dasd ssh_key
	BOOTIF"

for opt; do
	case "$opt" in
	s|single|1)
		SINGLEMODE=yes
		continue
		;;
	esac

	for i in $myopts; do
		case "$opt" in
		$i=*)	eval "KOPT_${i}=${opt#*=}";;
		$i)	eval "KOPT_${i}=yes";;
		no$i)	eval "KOPT_${i}=no";;
		esac
	done
done

[ "$KOPT_quiet" = yes ] || echo "Alpine Init $VERSION"

# enable debugging if requested
[ -n "$KOPT_debug_init" ] && set -x

# set default values
: ${KOPT_init:=/sbin/init}

# pick first keymap if found
for map in /etc/keymap/*; do
	if [ -f "$map" ]; then
		ebegin "Setting keymap ${map##*/}"
		zcat "$map" | loadkmap
		eend
		break
	fi
done

# start bootcharting if wanted
if [ "$KOPT_chart" = yes ]; then
	ebegin "Starting bootchart logging"
	/sbin/bootchartd start-initfs "$sysroot"
	eend 0
fi

# The following values are supported:
#   alpine_repo=auto         -- default, search for .boot_repository
#   alpine_repo=http://...   -- network repository
ALPINE_REPO=${KOPT_alpine_repo}
[ "$ALPINE_REPO" = "auto" ] && ALPINE_REPO=

# hide kernel messages
[ "$KOPT_quiet" = yes ] && dmesg -n 1

# optional blacklist
for i in ${KOPT_blacklist//,/ }; do
	echo "blacklist $i" >> /etc/modprobe.d/boot-opt-blacklist.conf
done

# determine if we are going to need networking
if [ -n "$KOPT_ip" ] || [ -n "$KOPT_nbd" ] || \
	is_url "$KOPT_apkovl" || is_url "$ALPINE_REPO"; then

	do_networking=true
else
	do_networking=false
fi

if [ -n "$KOPT_dasd" ]; then
	for mod in dasd_mod dasd_eckd_mod dasd_fba_mod; do
		modprobe $mod
	done
	for _dasd in $(echo "$KOPT_dasd" | tr ',' ' ' ); do
		echo 1 > /sys/bus/ccw/devices/"${_dasd%%:*}"/online
	done
fi

if [ "${KOPT_s390x_net%%,*}" = "qeth_l2" ]; then
	for mod in qeth qeth_l2 qeth_l3; do
		modprobe $mod
	done
	_channel="${KOPT_s390x_net#*,}"
	echo "$_channel" > /sys/bus/ccwgroup/drivers/qeth/group
	echo 1 > /sys/bus/ccwgroup/drivers/qeth/"${_channel%%,*}"/layer2
	echo 1 > /sys/bus/ccwgroup/drivers/qeth/"${_channel%%,*}"/online
fi

# make sure we load zfs module if root=ZFS=...
rootfstype=${KOPT_rootfstype}
if [ -z "$rootfstype" ]; then
	case "$KOPT_root" in
	ZFS=*) rootfstype=zfs ;;
	esac
fi

# load available drivers to get access to modloop media
ebegin "Loading boot drivers"

modprobe -a $(echo "$KOPT_modules $rootfstype" | tr ',' ' ' ) loop squashfs 2> /dev/null
if [ -f /etc/modules ] ; then
	sed 's/\#.*//g' < /etc/modules |
	while read module args; do
		modprobe -q $module $args
	done
fi
eend 0

if [ -n "$KOPT_cryptroot" ]; then
	cryptopts="-c ${KOPT_cryptroot}"
	if [ "$KOPT_cryptdiscards" = "yes" ]; then
		cryptopts="$cryptopts -D"
	fi
	if [ -n "$KOPT_cryptdm" ]; then
		cryptopts="$cryptopts -m ${KOPT_cryptdm}"
	fi
	if [ -n "$KOPT_cryptheader" ]; then
		cryptopts="$cryptopts -H ${KOPT_cryptheader}"
	fi
	if [ -n "$KOPT_cryptoffset" ]; then
		cryptopts="$cryptopts -o ${KOPT_cryptoffset}"
	fi
	if [ "$KOPT_cryptkey" = "yes" ]; then
		cryptopts="$cryptopts -k /crypto_keyfile.bin"
	elif [ -n "$KOPT_cryptkey" ]; then
		cryptopts="$cryptopts -k ${KOPT_cryptkey}"
	fi
fi

if [ -n "$KOPT_nbd" ]; then
	# TODO: Might fail because nlplug-findfs hasn't plugged eth0 yet
	configure_ip
	setup_nbd || echo "Failed to setup nbd device."
fi

# zpool reports /dev/zfs missing if it can't read /etc/mtab
ln -s /proc/mounts /etc/mtab

# check if root=... was set
if [ -n "$KOPT_root" ]; then
	if [ "$SINGLEMODE" = "yes" ]; then
		echo "Entering single mode. Type 'exit' to continue booting."
		sh
	fi

	ebegin "Mounting root"
	nlplug-findfs $cryptopts -p /sbin/mdev ${KOPT_debug_init:+-d} \
		$KOPT_root

	if echo "$KOPT_modules $rootfstype" | grep -qw btrfs; then
		/sbin/btrfs device scan >/dev/null || \
			echo "Failed to scan devices for btrfs filesystem."
	fi

	if [ -n "$KOPT_resume" ]; then
		echo "Resume from disk"
		if [ -e /sys/power/resume ]; then
			printf "%d:%d" $(stat -Lc "0x%t 0x%T" "$KOPT_resume") >/sys/power/resume
		else
			echo "resume: no hibernation support found"
		fi
	fi

	if [ "$KOPT_overlaytmpfs" = "yes" ]; then
		mkdir -p /media/root-ro /media/root-rw $sysroot/media/root-ro \
			$sysroot/media/root-rw
		mount -o ro $KOPT_root /media/root-ro
		mount -t tmpfs root-tmpfs /media/root-rw
		mkdir -p /media/root-rw/work /media/root-rw/root
		mount -t overlay -o lowerdir=/media/root-ro,upperdir=/media/root-rw/root,workdir=/media/root-rw/work overlayfs $sysroot
	else
		mount ${rootfstype:+-t} ${rootfstype} \
			-o ${KOPT_rootflags:-ro} \
			${KOPT_root#ZFS=} $sysroot
	fi

	eend $?
	cat /proc/mounts | while read DEV DIR TYPE OPTS ; do
		if [ "$DIR" != "/" -a "$DIR" != "$sysroot" -a -d "$DIR" ]; then
			mkdir -p $sysroot/$DIR
			mount -o move $DIR $sysroot/$DIR
		fi
	done
	sync
	exec /bin/busybox switch_root $sysroot $chart_init "$KOPT_init" $KOPT_init_args
	echo "initramfs emergency recovery shell launched"
	exec /bin/busybox sh
fi

if $do_networking; then
	repoopts="-n"
else
	repoopts="-b $repofile"
fi

# locate boot media and mount it
ebegin "Mounting boot media"
nlplug-findfs $cryptopts -p /sbin/mdev ${KOPT_debug_init:+-d} \
	${KOPT_usbdelay:+-t $(( $KOPT_usbdelay * 1000 ))} \
	$repoopts -a /tmp/apkovls
eend $?

# Setup network interfaces
if $do_networking; then
        configure_ip
fi

# early console?
if [ "$SINGLEMODE" = "yes" ]; then
	echo "Entering single mode. Type 'exit' to continue booting."
	sh
fi

# mount tmpfs sysroot
rootflags="mode=0755"
if [ -n "$KOPT_root_size" ]; then
	echo "WARNING: the boot option root_size is deprecated. Use rootflags instead"
	rootflags="$rootflags,size=$KOPT_root_size"
fi
if [ -n "$KOPT_rootflags" ]; then
	rootflags="$rootflags,$KOPT_rootflags"
fi

mount -t tmpfs -o $rootflags tmpfs $sysroot

if [ -z "$KOPT_apkovl" ]; then
	# Not manually set, use the apkovl found by nlplug
	if [ -e /tmp/apkovls ]; then
		ovl=$(head -n 1 /tmp/apkovls)
	fi
elif is_url "$KOPT_apkovl"; then
	# Fetch apkovl via network
	MACHINE_UUID=$(cat /sys/class/dmi/id/product_uuid 2>/dev/null)
	url="${KOPT_apkovl/{MAC\}/$MAC_ADDRESS}"
	url="${url/{UUID\}/$MACHINE_UUID}"
	ovl=/tmp/${url##*/}
	wget -O "$ovl" "$url" || ovl=
else
	ovl="$KOPT_apkovl"
fi

# parse pkgs=pkg1,pkg2
if [ -n "$KOPT_pkgs" ]; then
	pkgs=$(echo "$KOPT_pkgs" | tr ',' ' ' )
fi

# load apkovl or set up a minimal system
if [ -f "$ovl" ]; then
	ebegin "Loading user settings from $ovl"
	# create apk db and needed /dev/null and /tmp first
	apk add --root $sysroot --initdb --quiet

	unpack_apkovl "$ovl" $sysroot
	eend $? $errstr || ovlfiles=
	# hack, incase /root/.ssh was included in apkovl
	[ -d "$sysroot/root" ] && chmod 700 "$sysroot/root"
	pkgs="$pkgs $(cat $sysroot/etc/apk/world 2>/dev/null)"
fi

if [ -f "$sysroot/etc/.default_boot_services" -o ! -f "$ovl" ]; then
	# add some boot services by default
	rc_add devfs sysinit
	rc_add dmesg sysinit
	rc_add mdev sysinit
	rc_add hwdrivers sysinit
	rc_add modloop sysinit

	rc_add modules boot
	rc_add sysctl boot
	rc_add hostname boot
	rc_add bootmisc boot
	rc_add syslog boot

	rc_add mount-ro shutdown
	rc_add killprocs shutdown
	rc_add savecache shutdown

	rc_add firstboot default

	rm -f "$sysroot/etc/.default_boot_services"
fi

if [ "$KOPT_splash" != "no" ]; then
	echo "IMG_ALIGN=CM" > /tmp/fbsplash.cfg
	for fbdev in /dev/fb[0-9]; do
		[ -e "$fbdev" ] || break
		num="${fbdev#/dev/fb}"
		for img in /media/*/fbsplash$num.ppm; do
			[ -e "$img" ] || break
			config="${img%.*}.cfg"
			[ -e "$config" ] || config=/tmp/fbsplash.cfg
			fbsplash -s "$img" -d "$fbdev" -i "$config"
			break
		done
	done
	for fbsplash in /media/*/fbsplash.ppm; do
		[ -e "$fbsplash" ] && break
	done
fi

if [ -n "$fbsplash" ] && [ -e "$fbsplash" ]; then
	ebegin "Starting bootsplash"
	mkfifo $sysroot/$splashfile
	config="${fbsplash%.*}.cfg"
	[ -e "$config" ] || config=/tmp/fbsplash.cfg
	setsid fbsplash -T 16 -s "$fbsplash" -i $config -f $sysroot/$splashfile &
	eend 0
else
	KOPT_splash="no"
fi

if [ -f $sysroot/etc/fstab ]; then
	has_fstab=1
	fstab=$sysroot/etc/fstab

	# let user override tmpfs size in fstab in apkovl
	mountopts=$(awk '$2 == "/" && $3 == "tmpfs" { print $4 }' $sysroot/etc/fstab)
	if [ -n "$mountopts" ]; then
		mount -o remount,$mountopts $sysroot
	fi
	# move throot:x:0:0:root:/root:/bin/ash
bin:x:1:1:bin:/bin:/bin/false
daemon:x:2:2:daemon:/sbin:/bin/false
adm:x:3:4:adm:/var/adm:/bin/false
lp:x:4:7:lp:/var/spool/lpd:/bin/false
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
mail:x:8:12:mail:/var/spool/mail:/bin/false
news:x:9:13:news:/usr/lib/news:/bin/false
uucp:x:10:14:uucp:/var/spool/uucppublic:/bin/false
operator:x:11:0:operator:/root:/bin/sh
man:x:13:15:man:/usr/man:/bin/false
postmaster:x:14:12:postmaster:/var/spool/mail:/bin/false
cron:x:16:16:cron:/var/spool/cron:/bin/false
ftp:x:21:21::/home/ftp:/bin/false
sshd:x:22:22:sshd:/dev/null:/bin/false
at:x:25:25:at:/var/spool/cron/atjobs:/bin/false
squid:x:31:31:Squid:/var/cache/squid:/bin/false
gdm:x:32:32:GDM:/var/lib/gdm:/bin/false
xfs:x:33:33:X Font Server:/etc/X11/fs:/bin/false
games:x:35:35:games:/usr/games:/bin/false
named:x:40:40:bind:/var/bind:/bin/false
mysql:x:60:60:mysql:/var/lib/mysql:/bin/false
postgres:x:70:70::/var/lib/postgresql:/bin/sh
apache:x:81:81:apache:/home/httpd:/bin/false
nut:x:84:84:nut:/var/state/nut:/bin/false
cyrus:x:85:12::/usr/cyrus:/bin/false
vpopmail:x:89:89::/var/vpopmail:/bin/false
ntp:x:123:123:NTP:/var/empty:/bin/false
alias:x:200:200::/var/qmail/alias:/bin/false
qmaild:x:201:200::/var/qmail:/bin/false
qmaill:x:202:200::/var/qmail:/bin/false
qmailp:x:203:200::/var/qmail:/bin/false
qmailq:x:204:201::/var/qmail:/bin/false
qmailr:x:205:201::/var/qmail:/bin/false
qmails:x:206:201::/var/qmail:/bin/false
postfix:x:207:207:postfix:/var/spool/postfix:/bin/false
smmsp:x:209:209:smmsp:/var/spool/mqueue:/bin/false
portage:x:250:250:portage:/var/tmp/portage:/bin/false
guest:x:405:100:guest:/dev/null:/dev/null
nobody:x:65534:65534:nobody:/:/bin/false
distcc:x:240:2:distccd:/dev/null:/bin/false
