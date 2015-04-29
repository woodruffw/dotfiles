#!/bin/sh

# battery.sh
# kills dropbox and spotify processes when AC power is disconnected
# based on http://www.thinkwiki.org/wiki/ACPI_action_script_for_battery_events
# installed on mercury 4/29/15 /etc/acpi/battery.sh

ac_status=`awk '/^state: / { print $2 }' /proc/acpi/ac_adapter/AC/state`
programs="dropbox spotify"

if [ "$ac_status" = "off-line" ]; then
	for program in $programs; do
		for process in `pidof $program`; do
			logger "$0: killing $process ($program)"
			kill -9 $process
		done
	done
fi
