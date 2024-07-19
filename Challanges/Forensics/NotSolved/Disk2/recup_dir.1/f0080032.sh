#!/bin/sh

VERSION=3.4.1-r1
sysconfdir=/etc/mkinitfs
datadir=/usr/share/mkinitfs

config="$sysconfdir"/mkinitfs.conf
init="$datadir"/initramfs-init
fstab="$datadir"/fstab
passwd="$datadir"/passwd
group="$datadir"/group

startdir=$PWD

initfscomp=gzip

feature_files() {
	local dir="$1"
	local suffix="$2"
	local glob file fdir
	for f in $features; do
		for fdir in $features_dirs; do
			[ -f "$fdir/$f.$suffix" ] || continue
			for glob in $(sed -e '/^$/d' -e '/^#/d' -e "s|^/*|$dir|" "$fdir/$f.$suffix"); do
				for file in $glob; do
					if [ -d $file ]; then
						find $file -type f
					elif [ -e "$file" ]; then
						echo $file
					fi
				done
			done
			break
		done
	done
}

initfs_base() {
	local i= dirs= glob= file=
	for i in dev proc sys sbin bin run .modloop lib/modules media/cdrom \
	    etc/apk media/floppy media/usb newroot; do
		dirs="$dirs $tmpdir/$i"
	done
	mkdir -p $dirs

	local oldpwd="$PWD"
	cd "${basedir}"
	lddtree -R "$basedir" -l --no-auto-root \
		$(feature_files "$basedir" files) \
		\
		| sed -e "s|^$basedir||" | sort -u \
		| cpio --quiet -pdm "$tmpdir" || return 1

	# copy init
	cd "$startdir"
	install -m755 "$init" "$tmpdir"/init || return 1
	# copy modloop signature
	if [ -n "$modloop_sig" ]; then
		install -Dm644 "$modloop_sig" \
			"$tmpdir"/var/cache/misc/${modloop_sig##*/}
	fi
	for i in "$fstab" "$passwd" "$group"; do
		install -Dm644 "$i" "$tmpdir"/etc/${i##*/} || return 1
	done
	cd "$oldpwd"
}

find_kmod_deps() {
	awk -v prepend="/lib/modules/$kernel/" -v modulesdep="${basedir}lib/modules/$kernel/modules.dep" '
function recursedeps(k,		j, dep) {
	if (k in visited)
		return;
	visited[k] = 1;
	split(deps[k], dep, " ");
	for (j in dep)
		recursedeps(dep[j]);
	print(prepend k);
}

BEGIN {
	if (modulesdep == "")
		modulesdep="modules.dep";
	FS = ": ";
	while ( (getline < modulesdep) > 0) {
		if (substr($0,1,1) == "/") {
			gsub(prepend, "", $1);
			gsub(prepend, "", $2);
		}
		deps[$1] = $2;
	}
}

{
	mod[$0] = 1;
}

END {
	for (i in mod)
		recursedeps(i);
}'
}

find_kmods() {
	local oldpwd="$PWD"
	cd "$kerneldir" || return 1
	for file in $(feature_files "${kerneldir}/" modules); do
		echo ${file#${kerneldir%/}/}
	done | find_kmod_deps
	cd "$oldpwd"
}

initfs_kmods() {
	[ -z "$nokernel" ] || return 0
	local glob= file= files= dirs=
	rm -rf "$tmpdir"/lib/modules
	# make sure we have modules.dep
	if ! [ -f "$kerneldir"/modules.dep ]; then
		depmod -b "${basedir}" $kernel
	fi
	local oldpwd="$PWD"
	cd "${basedir}"
	for file in $(find_kmods); do
		echo "${file#/}"
	done | sort -u | cpio --quiet -pdm "$tmpdir" || return 1
	for file in modules.order modules.builtin; do
		if [ -f "$kerneldir"/$file ]; then
			cp "$kerneldir"/$file "$tmpdir"/lib/modules/$kernel/
		fi
	done
	depmod $kernel -b "$tmpdir"
	cd "$oldpwd"
}

initfs_firmware() {
	[ -z "$nokernel" ] || return 0
	rm -rf "$tmpdir"/lib/firmware
	mkdir -p "$tmpdir"/lib/firmware
	find "$tmpdir"/lib/modules -type f -name "*.ko" | xargs modinfo -F firmware | sort -u | while read FW; do
		[ -e "${basedir}/lib/firmware/${FW}" ] && install -pD "${basedir}/lib/firmware/${FW}" "$tmpdir"/lib/firmware/$FW
	done
	return 0
}

initfs_apk_keys() {
	mkdir -p "$tmpdir"/etc/apk/keys
	[ "$hostkeys" ] && cp "/etc/apk/keys/"* "$tmpdir"/etc/apk/keys/
	cp "${basedir}etc/apk/keys/"* "$tmpdir"/etc/apk/keys/
}

initfs_cpio() {
	if [ -n "$list_sources" ]; then
		(cd "$tmpdir" && find . | sort)
		return
	fi
	rm -f $outfile
	umask 0022
	(cd "$tmpdir" && find . | sort | cpio --quiet -o -H newc | $comp) > $outfile
}

cmd_exists() {
	local cmd="$1"
	if ! command -v "$cmd" >/dev/null 2>&1; then
		echo "Command \"$cmd\" is not available."
		exit 1
	fi
}

usage() {
	cat <<EOF
usage: mkinitfs [-hkKLln] [-b basedir] [-c configfile] [-F features] [-f fstab]
		[-C initramfs compression] [-i initfile] [-o outfile]
		[-P featuresdir] [-t tempdir] [kernelversion]
options:
	-b  prefix files and kernel modules with basedir
	-c  use configfile instead of $config
	-C  initramfs compression (gzip|xz defaults to $initfscomp)
	-f  use fstab instead of $fstab
	-F  use specified features
	-h  print this help
	-i  use initfile as init instead of $init
	-k  keep tempdir
	-K  copy also host keys to initramfs
	-l  only list files that would have been used
	-L  list available features
	-n  don't include kernel modules or firmware
	-o  set another outfile
	-P  prepend features.d search path
	-q  Quiet mode
	-s  Include modloop signature
	-t  use tempdir when creating initramfs image

EOF
	exit 1
}

# main
features_dirs=${features_dir:-"${basedir%/:-}/${sysconfdir#/}/features.d"}

while getopts "b:c:C:f:F:hi:kKLlno:P:qs:t:" opt; do
	case "$opt" in
		b) basedir="$OPTARG";;
		c) config="$OPTARG";;
		C) initfscomp="$OPTARG";;
		F) myfeatures="$OPTARG";;
		f) fstab="$OPTARG";;
		h) usage;;
		i) init=$OPTARG;;
		k) keeptmp=1;;
		K) hostkeys=1;;
		L) list_features=1;;
		l) list_sources=1;;
		n) nokernel=1;;
		o) outfile="$OPTARG";;
		P) features_dirs="$OPTARG $features_dirs";;
		q) quiet=1;;
		s) modloop_sig="$OPTARG";;
		t) tmpdir="$OPTARG";;
		*) usage;;
	esac
done
shift $(( $OPTIND - 1 ))

. $(readlink -f "$config")
[ -n "$myfeatures" ] && features="$myfeatures"

if [ -n "$list_features" ]; then
	for dir in $features_dirs; do
		for i in $dir/*.files $dir/*.modules; do
			[ -e "$i" ] || continue
			file=${i##*/}
			echo ${file%.*}
		done
	done | sort -u
	exit 0
fi

basedir="${basedir%/}/"
[ "${basedir}" = "${basedir#/}" ] && basedir="${PWD}/${basedir}"


if [ -z "$nokernel" ]; then
	[ -n "$1" ] && kernel="$1"
	[ -z "$kernel" ] && kernel=$(uname -r)
	kerneldir="${basedir}lib/modules/$kernel"

	kflavor=${kernel##*-}
	[ "$kflavor" = "$kernel" ] && kflavor=vanilla
else
	kflavor=generic
fi

if [ -z "$outfile" ]; then
	outfile="${basedir}boot/initramfs-${kflavor}"
fi

if [ -z "$nokernel" ] && [ ! -d "$kerneldir" ]; then
	echo "$kerneldir does not exist or is not a directory"
	exit 1
fi

if [ -n "$DEBUG_KMOD" ]; then
	find_kmods
	exit 0
fi

if [ -z "$tmpdir" ]; then
	tmpdir=$(mktemp -d /tmp/mkinitfs.XXXXXX)
else
	mkdir -p "$tmpdir"
fi

if [ -z "$keeptmp" ]; then
	[ -d "$tmpdir" ] && rm -rf "$tmpdir"/*
fi

if [ -z "$list_sources" ] && [ -z "$quiet" ]; then
	echo "==> initramfs: creating $outfile"
fi

case "$initfscomp" in
	gzip) comp="gzip -9" ;;
	xz) cmd_exists xz; comp="xz -C crc32 -T 0" ;;
	*) echo "Initramfs compression \"$initfscomp\" not supported!"; exit 1 ;;
esac

initfs_base \
	&& initfs_kmods \
	&& initfs_firmware \
	&& initfs_apk_keys \
	&& initfs_cpio
rc=$?

# cleanup
if [ -z "$keeptmp" ]; then
	[ -d "$tmpdir" ] && rm -rf "$tmpdir"
fi

exit $rc
