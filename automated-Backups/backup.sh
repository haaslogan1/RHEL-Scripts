#!/bin/bash

# Example usage: 
# ./backup.sh daily time
# ./backup.sh weekly time
# ./backup.sh monthly day-of-week time
# ./backup.sh yearly month/day time
# ./backup.sh usage

# ***** GLOBALS *****

# ---------- Command arguments ----------
USER=$(whoami)
# ---------- Global variables ----------
# the user is creating automated daily backup
DAILY=false
# the user is creating automated weekly backup
WEEKLY=false
# the user is creating automated weekly backup
MONTHLY=false
# the user is creating automated yearly backup
YEARLY=false
# the user wants to learn about how to use this script
USAGE=false
# Time in hours
HOUR=0
# Time in minutes
MIN=0 

# (crontab -l 2>/dev/null; echo "*/5 * * * * /path/to/job -with args") | crontab -

# ---------- Script functions -----------
# Info reporting functions
info() {
    echo >&2 "[INFO] $1"
}


# Error reporting functions
err() {
    echo >&2 "[ERROR] $1"
}

# inform the user how to use this script
print_usage() {
	echo "
	
Examples:
./backup.sh daily military_time
./backup.sh monthly day-of-week military_time
./backup.sh yearly month/day military_time
./backup.sh usage	


Examples with real input:
./backup.sh daily 13:00
./backup.sh monthly 1 13:00
./backup.sh yearly 1/12 13:00
./backup.sh usage


" 
	exit 1
}

# Parse CLI args
parse_arguments() {
	

	if [ "$#" -eq 0 ] ; then
    		err "Must specify command line arguments"
			print_usage
        	exit 1
    	fi
	case ${1} in
		daily)
			DAILY=true
			;;
		weekly)
			WEEKLY=true
			;;
		monthly)
			MONTHLY=true
			;;
		yearly)
			YEARLY=true
			;;
		*)
		err "Argument 1 must specify one of the following: daily, weekly, monthly, yearly" 
		print_usage
		exit 1
	esac
	shift
}

daily() {
	info "daily"

	if  [ "$#" != 2 ]; then
		err "Must include only two arguments for the daily option, not "$#" arguments"		
		print_usage
	fi
	
	if echo ${2} | grep -q -E  "[0-9]+:[0-9]+"; then
		# Using the internal field seperator (IFS) variable to split the time into hours and mins
		IFS=':' read -ra TIME <<< ${2}
		
		HOUR=${TIME[0]}
		MIN=${TIME[1]}
	else
		err "time format must be: [0-9]+:[0-9]+. Not "${2}.""
		print_usage
	fi

	echo "$HOUR\n$MIN"
	
	if [ "$HOUR" -gt 23 ]; then
		err " the time cannnot be above 23 hours."
		print_usage
	elif [ "$HOUR" -lt 0 ]; then
			err " the time cannnot be below 0 hours."
		print_usage
	elif [ "$MIN" -lt 0 ]; then
		err "the minue must be between 0 and 59 minutes."
		print_usage
	elif [ "$MIN" -gt 59 ]; then
		err "the time must be between 0 and 59 minutes."
		print_usage
	fi
	if [ $USER == "root" ]; then
		# Create the backup directory for the new backup
        	(mkdir /${USER}/automatedBackups)		
	else
		# Create the backup directory for the new backup
		(mkdir /home/${USER}/automatedBackups)
	fi

	# Clear the directory and add a new backup once per day at the given mins and hours
	(crontab -l 2>/dev/null; echo "${MIN} ${HOUR} * * * rm -rf /home/${USER}/automatedBackups/*; cp /home/${USER}/* /home/${USER}/automatedBackups/") | crontab -	
	
}
# 
# weekly() {
# 
# }
# 
# monthly() {
# 
# }
# 
# yearly() {
# 
# }

main() {
	parse_arguments "$@"
	if $DAILY; then
		info "made it!"
		daily "$@"
# 	elif $WEEKLY; then
# 		weekly
# 	elif $MONTHLY; then
# 		monthly
# 	elif $YEARLY; then
# 		yearly
 	fi
	exit 0
}



# Run the script
main $*