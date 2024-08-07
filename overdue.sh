#!/bin/bash
# 2024-07-25
# overdue script author and source: https://github.com/tylerjl/overdue/blob/master/src/overdue.sh

bold='\033[1m'
yellow="\033[0;93m"
none='\033[00m'

if	[[ ${EUID} != 0 ]] ; then
	echo -e "${yellow}${bold} You must be root to run this program. ${none}"
	exit 1
fi

pids="$(lsof -d DEL 2>/dev/null | awk '$8~/\/usr\/lib/ {printf $2" "}')"

	[[ -z ${pids} ]] && exit 0

services="$(ps -o unit= ${pids} | sort -u)"			# SC2086 Omited double quotes for proper operation.

	[[ -z ${services} ]] && exit 0


	echo -e "${yellow}${bold}  Daemons/units with stale file handles open to upgraded libraries: ${none}"

for i in $services; do

    	echo "  ● ${i}"

done
