#!/bin/bash
# syuscript 2024-07-31
# dependencies: supplied script >(overdue) rebuild-detector >(checkrebuild) lsof
# https://bbs.archlinux.org/viewtopic.php?id=246036
# https://bbs.archlinux.org/viewtopic.php?id=132322

BC=$(tput bold; tput setaf 6)											# bold cyan font
BY=$(tput bold; tput setaf 3)											# bold yellow font
OFF=$(tput sgr0)												# turn off fancy fonts
Modules=""

if	! which checkrebuild lsof &>/dev/null; then								# Check/install deps
	printf '\f%s\f\n' "${BC} Missing dependencies: rebuild-detector lsof. ${OFF}"
	sudo pacman -S --needed rebuild-detector lsof
fi

logdest="${HOME}/update-logs"
PrepRep=$(find "${HOME}"/Desktop/prep4ud.dir/ -type f -printf "%f\n" 2>/dev/null | sort -V | tail -1)		# Find latest prep4ud report
Kern=$(uname -s)												# Get current running kernel name

	[[ ! -d ${logdest} ]] && mkdir -p "${logdest}"								# Check/create log directory
	[[ ! -d  ${logdest}/multiple-runs ]] && mkdir -p "${logdest}/multiple-runs"				# Check/create multiple-runs directory

if	[[ -f "${logdest}/$(date '+%Y-%m-%d').log" ]]; then						 	# For multiple runs, move current
	mv "${logdest}/$(date '+%Y-%m-%d').log" "${logdest}/multiple-runs/$(date '+%Y-%m-%d-%R.%S').log"	# log to multiple-runs directory
fi
	find "${logdest}"/* -maxdepth 0 -type f               | sort -V |  head -n -4  |  xargs rm -f		# Maintain 5 logs in logdest
	find "${logdest}"/multiple-runs/* -maxdepth 0 -type f | sort -V |  head -n -4  |  xargs rm -f		# Maintain 5 logs in multiple-runs

tee_data(){
	tee -a "${logdest}/$(date '+%Y-%m-%d').log"
}

	printf '\f%s\f\n' "${BC}  Contents of prep4ud report ${PrepRep}: ${OFF}"
	cat "${HOME}"/Desktop/prep4ud.dir/"${PrepRep}" 2>/dev/null || { echo "  Prep4ud report NA."; }

	printf '\f%s\f\n' "${BC}  Running pacman -Syu....  ${OFF}"				|& tee_data
	sudo pacman -Syu --color=always 							|& tee_data

Modules=$(find /usr/lib/modules -maxdepth 1 -printf "%f\n" | grep -v modules | sort -V | tail -n1)		# Prep for kernel update check

	printf '\f%s\n' "${BC}  Checking kernel update.... ${OFF}"				|& tee_data

if	[[ ${Modules} != $(uname -r) ]]; then
	printf '%s\n' "${BY}  Kernel was updated.${OFF}"					|& tee_data
	printf '%s\n' "  Running kernel: $(uname -sr)"						|& tee_data
	printf '%s\n' "  Updated Kernel: $(pacman -Q "${Kern,,}")"				|& tee_data	# Convert 'Kern' to lower case.
fi														# ${Kern,,} ie: Linux to linux
	[[ ${Modules} == $(uname -r) ]] && printf '%s\n' "  Running kernel was not updated." 	|& tee_data


	printf '\f%s\n' "${BC}  Running overdue script..... ${OFF}"				|& tee_data
if	lsof 2>/dev/null | grep -q 'DEL.*lib' ; then
	sudo "$(which overdue)"									|& tee_data
    else
	printf '%s\n' "  No daemons/units with stale file handles."				|& tee_data
fi
	printf '\f%s\n' "${BC}  Running checkrebuild.... ${OFF}"				|& tee_data
	printf '%s\n' "  No output indicates no action needed."					|& tee_data
	checkrebuild -v 									|& tee_data

	printf '\f%s\n' "${BC}  To clean pacman cache run: ${OFF}"
	printf '%s\n' "  paccache --cachedir /var/cache/pacman/pkg/ --uninstalled --remove "
	printf '%s\n' "  paccache --cachedir /var/cache/pacman/pkg/ --remove --keep 2 "

	printf '\f%s\n' "${BC}  To soft reboot run: ${OFF}"
	printf '%s\n' "  systemctl soft-reboot"

	printf '\f%s\n' "${BC}  Log available run: ${OFF}"
	printf '%s\n\f' "  cat ${logdest}/$(date '+%Y-%m-%d').log"
