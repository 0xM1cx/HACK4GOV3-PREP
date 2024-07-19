#!/bin/sh
# Detect AC power or not in a portable way
# Exit 0 if on AC power, 1 if not and 255 if we don't know how to work it out

# Copyright (c) 2007-2015 The OpenRC Authors.
# See the Authors file at the top-level directory of this distribution and
# https://github.com/OpenRC/openrc/blob/master/AUTHORS
#
# This file is part of OpenRC. It is subject to the license terms in
# the LICENSE file found in the top-level directory of this
# distribution and at https://github.com/OpenRC/openrc/blob/master/LICENSE
# This file may not be copied, modified, propagated, or distributed
#    except according to the terms contained in the LICENSE file.

if [ -f /proc/acpi/ac_adapter/*/state ]; then
	cat /proc/acpi/ac_adapter/*/state | while read line; do
		case "$line" in
		"state:"*"off-line") exit 128;;
		esac
	done
elif [ -f /sys/class/power_supply/*/online ]; then
	cat /sys/class/power_supply/*/online | while read line; do
		[ "${line}" = 0 ] && exit 128
	done
elif [ -f /proc/pmu/info ]; then
	cat /proc/pmu/info | whi