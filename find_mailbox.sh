#!/usr/bin/ksh

# 07.12.2016 jcarlin created
# Script for finding Kolab users on the backend of a cyrus murder
# The script assumes you are using clusterssh or have a file you can create that has all your backends identified and
# that you have ssh set up so you can ssh into all those backends and
# that you can sudo on those systems... 

USER=${1}
FIRSTA=$(echo ${USER} | cut -c1)

ERROR=0
[[ -z ${USER} ]] && ERROR=1
[[ -z ${HOME} ]] && ERROR=2
[[ -z $(ls ${HOME}/.clusterssh/config 2>/dev/null) ]] && ERROR=3
[[ -z $(grep '^backend' ${HOME}/.clusterssh/config) ]] && ERROR=4

case ${ERROR} in
	0) ;;
	1) echo "Enter a user name to search."
		exit;;
	2) echo "Missing \${HOME} environment variable."
		exit;;
	3) echo "Missing clusterssh config file"
		exit;;
	4) echo "Missing backend server list in clusterssh config file."
		exit;;
	*) exit;;
esac
	

for X in $(grep '^backend' ${HOME}/.clusterssh/config | sed -e "s/backend = //"); do {
	print -n "."
	SHORT=$(echo ${X}|cut -d. -f1)
	RESULT=$(ssh ${X} "sudo ls -d /srv/imap/${SHORT}/spool/${FIRSTA}/user/${USER} 2>/dev/null")
        if [[ ! -z ${RESULT} ]]; then
		print ""
		echo "Found ${USER} on ${X}: ${RESULT}"
		exit
	fi
}; done
exit
