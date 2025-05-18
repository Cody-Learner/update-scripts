#!/bin/bash
# syuscript 2025-05-18
# dependencies: supplied script >(overdue) rebuild-detector >(checkrebuild) lsof
# https://bbs.archlinux.org/viewtopic.php?id=246036
# https://bbs.archlinux.org/viewtopic.php?id=132322

BC=$(tput bold; tput setaf 6)											# bold cyan font
BY=$(tput bold; tput setaf 3)											# bold yellow font
OFF=$(tput sgr0)												# turn off fancy fonts

if	! which checkrebuild lsof &>/dev/null; then								# Check/install deps
	printf '\n%s\n\n' "${BC} Missing dependencies: rebuild-detector lsof. ${OFF}"
	sudo pacman -S --needed rebuild-detector lsof
fi

logdest="${HOME}/update-logs"
PrepRep=$(find "${HOME}"/Desktop/prep4ud.dir/ -type f -printf "%f\n" 2>/dev/null | sort -V | tail -1)		# Find latest prep4ud report

	[[ ! -d ${logdest} ]] && mkdir -p "${logdest}"								# Check/create log directory
	[[ ! -d  ${logdest}/multiple-runs ]] && mkdir -p "${logdest}/multiple-runs"				# Check/create multiple-runs directory

if	[[ -f "${logdest}/$(date '+%Y-%m-%d').log" ]]; then						 	# For multiple runs, move current
	mv "${logdest}/$(date '+%Y-%m-%d').log" "${logdest}/multiple-runs/$(date '+%Y-%m-%d-%R.%S').log"	# log to multiple-runs directory
fi
	find "${logdest}"/* -maxdepth 0 -type f               | sort -V |  head -n -4  |  xargs rm -f		# Maintain 5 logs in logdest
	find "${logdest}"/multiple-runs/* -maxdepth 0 -type f | sort -V |  head -n -4  |  xargs rm -f		# Maintain 5 logs in multiple-runs

kernel_check(){

	file /boot/vmlinuz* |
	awk '/Linux kernel x86 boot executable/ {
		split($1, a, "-");
		kernel_type = a[3] ? a[2] "-" a[3] : a[2];
		sub(/:$/, "", kernel_type);
		match($0, /version ([^ ]+)/, v);
		if (v[1]) {print kernel_type, v[1]}
		}'
}

tee_data(){
	sudo tee -a "${logdest}/$(date '+%Y-%m-%d').log"
}

	kernel_check > /tmp/kern-before

	printf '\n%s\n\n' "${BC}  Contents of prep4ud report ${PrepRep}: ${OFF}"
	cat "${HOME}"/Desktop/prep4ud.dir/"${PrepRep}" 2>/dev/null || { echo "  Prep4ud report NA."; }

	printf '\n%s\n\n' "${BC}  Running pacman -Syu....  ${OFF}"				|& tee_data
	sudo pacman -Syu --color=always 							|& tee_data

	kernel_check > /tmp/kern-after

	printf '\n%s\n' "${BC}  Checking kernel update.... ${OFF}"				|& tee_data

before=$(md5sum /tmp/kern-before | cut -d" " -f1)
after=$(md5sum /tmp/kern-after | cut -d" " -f1)

if	[[ ${after} != ${before} ]]; then
	printf '%s\n' "${BY}  Updated kernel/s:${OFF}"						|& tee_data
	comm -23 <(sort /tmp/kern-after) <(sort /tmp/kern-before) |
		while IFS= read -r updated_kernel; do
      		printf '%s\n' "  ${updated_kernel}${OFF}"					|& tee_data
    		done
	printf   '%s\n' "${BY}  Running kernel:${OFF}"						|& tee_data
	printf   '%s\n'   "  $(uname -rs | tr '[:upper:]' '[:lower:]') ${OFF}"			|& tee_data
    else
  	printf '%s\n' "${BC}  Kernel/s not updated.${OFF}"					|& tee_data
fi

	printf '\n%s\n' "${BC}  Running overdue script..... ${OFF}"				|& tee_data
if	lsof 2>/dev/null | grep -q 'DEL.*lib' ; then
	sudo "$(which overdue)"									|& tee_data
    else
	printf '%s\n' "  No daemons/units with stale file handles."				|& tee_data
fi
	printf '\n%s\n' "${BC}  Running checkrebuild.... ${OFF}"				|& tee_data
	printf '%s\n' "  No output indicates no action needed."					|& tee_data
	checkrebuild -v 									|& tee_data

	printf '\n%s\n' "${BC}  To clean pacman cache run: ${OFF}"
	printf '%s\n' "  paccache --cachedir /var/cache/pacman/pkg/ --uninstalled --remove "
	printf '%s\n' "  paccache --cachedir /var/cache/pacman/pkg/ --remove --keep 2 "

	printf '\n%s\n' "${BC}  To soft reboot run: ${OFF}"
	printf '%s\n' "  systemctl soft-reboot"

	printf '\n%s\n' "${BC}  Log available run: ${OFF}"
	printf '%s\n\n' "  cat ${logdest}/$(date '+%Y-%m-%d').log"
