#!/bin/bash

# Example usage: 
# ./backup.sh daily time
# ./backup.sh weekly time
# ./backup.sh monthly day-of-week time
# ./backup.sh yearly month/day time
# ./backup.sh usage

# ***** GLOBALS *****

# ---------- Command arguments ----------
# find the user executing this script
# the backup will be saved for this user's profile
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
# Month
MONTH=0
# Day in numeric form
DAY=0

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
./backup.sh weekly day-of-week miliary_time
./backup.sh monthly day-of-month military_time
./backup.sh yearly month/day military_time
./backup.sh usage	


Examples with real input:
./backup.sh daily 13:00
./backup.sh weekly Mon 13:00
./backup.sh monthly 1 13:00
./backup.sh yearly 1/12 13:00
./backup.sh usage


" 
	exit 1
}

# Parse CLI args
parse_arguments() {
	
	# Check whether or not command line args were passed in by the user
	if [ "$#" -eq 1 ] ; then
			# If there are no args passed in, we cannot proceed to create the cron task
    		err "Must specify command line arguments"
			print_usage
        	exit 1
    	fi
    # switch case for the first option parsed in after the script's file path
	case ${1} in
		# create a daily cron task
		daily)
			DAILY=true
			;;
		# create a weekly cron task
		weekly)
			WEEKLY=true
			;;
		# create a monthly cron task
		monthly)
			MONTHLY=true
			;;
		# create a yearly cron task
		yearly)
			YEARLY=true
			;;
		*)
			# invalid option from the user
			err "Argument 1 must specify one of the following: daily, weekly, monthly, yearly" 
			print_usage
			exit 1
	esac
}

# function to create a daily backup cron task
daily() {
	# we need exactly two args after the filepath
	if  [ "$#" != 2 ]; then
		err "Must include only two arguments for the daily option, not "$#" arguments"		
		print_usage
	fi
	
	# ensure that the second arg matches a time
	if echo ${2} | grep -q -E  "[0-9]+:[0-9]+"; then
		# Using the internal field seperator (IFS) variable to split the time into hours and mins
		IFS=':' read -ra TIME <<< ${2}
		
		# set the hour and min global variables
		HOUR=${TIME[0]}
		MIN=${TIME[1]}
	else
		# end the script as the format is not correct
		err "time format must be: [0-9]+:[0-9]+. Not "${2}.""
		print_usage
	fi

	# check for an invalid hour portion of the time stamp
	if [ "$HOUR" -gt 23 ]; then
		err " the time cannnot be above 23 hours."
		print_usage
	# check for an invalid hour portion of the time stamp
	elif [ "$HOUR" -lt 0 ]; then
		err " the time cannnot be below 0 hours."
		print_usage
	# check for an invalid min portion of the time stamp
	elif [ "$MIN" -lt 0 ]; then
		err "the minue must be between 0 and 59 minutes."
		print_usage
	#  check for an invalid min portion of the time stamp
	elif [ "$MIN" -gt 59 ]; then
		err "the time must be between 0 and 59 minutes."
		print_usage
	fi
	
	# check if the user is root (different home directory)
	if [ $USER == "root" ]; then
		# Create the backup directory for the new backup
        	(mkdir /${USER}/automatedBackups 2> /dev/null)		
	else
		# Create the backup directory for the new backup
		(mkdir /home/${USER}/automatedBackups 2> /dev/null)
	fi

	# Clear the directory and add a new backup once per day at the given mins and hours
	(crontab -l 2>/dev/null; echo "${MIN} ${HOUR} * * * rm -rf /home/${USER}/automatedBackups/*; cp /home/${USER}/* /home/${USER}/automatedBackups/") | crontab -	
	
}

# Evample: weekly use case:
# /backup.sh weekly Mon 13:00
# create a weekly cron task to back up directories  
weekly() {
	
	# we need exactly three args after the filepath
	if  [ "$#" != 3 ]; then
		err "Must include only two arguments for the daily option, not "$#" arguments"		
		print_usage
	fi


	# ensure that the second arg matches a time
	if echo ${3} | grep -q -E  "[0-9]+:[0-9]+"; then
		# Using the internal field seperator (IFS) variable to split the time into hours and mins
		IFS=':' read -ra TIME <<< ${3}
		
		# set the hour and min global variables
		MONTH=${TIME[0]}
		DAY=${TIME[1]}
	
	else
		# end the script as the format is not correct
		err "time format must be: [0-9]+:[0-9]+. Not "${2}.""
		print_usage
	fi

	# check for an invalid hour portion of the time stamp
	if [ "$HOUR" -gt 23 ]; then
		err " the time cannnot be above 23 hours."
		print_usage
	# check for an invalid hour portion of the time stamp
	elif [ "$HOUR" -lt 0 ]; then
		err " the time cannnot be below 0 hours."
		print_usage
	# check for an invalid min portion of the time stamp
	elif [ "$MIN" -lt 0 ]; then
		err "the minue must be between 0 and 59 minutes."
		print_usage
	#  check for an invalid min portion of the time stamp
	elif [ "$MIN" -gt 59 ]; then
		err "the time must be between 0 and 59 minutes."
		print_usage
	fi
	
	# check if the user is root (different home directory)
	if [ $USER == "root" ]; then
		# Create the backup directory for the new backup
		(mkdir /${USER}/automatedBackups 2> /dev/null)
		# Clear the directory and add a new backup once per day at the given mins and hours
		(crontab -l 2>/dev/null; echo "${MIN} ${HOUR} * * ${2} rm -rf /${USER}/automatedBackups/*; tar -czf /${USER}/automatedBackups/${USER}_${HOUR}_${MIN}.tar.gz /${USER}/ ") | crontab -	
	else
		# Create the backup directory for the new backup
		(mkdir /home/${USER}/automatedBackups 2> /dev/null)
		# Clear the directory and add a new backup once per day at the given mins and hours
		(crontab -l 2>/dev/null; echo "${MIN} ${HOUR} * * ${2} rm -rf /home/${USER}/automatedBackups/*; tar -czf  /home/${USER}/automatedBackups/${USER}_${HOUR}_${MIN}.tar.gz  /home/${USER}/ ") | crontab -
	fi
	
}




# Example: monthly use case:
# ./backup.sh monthly 1 13:00
# create a weekly cron task to back up directories  
monthly() {
	
	# we need exactly three args after the filepath
	if  [ "$#" != 3 ]; then
		err "Must include only two arguments for the daily option, not "$#" arguments"		
		print_usage
	fi


	# ensure that the second arg matches a time
	if echo ${3} | grep -q -E  "[0-9]+:[0-9]+"; then
		# Using the internal field seperator (IFS) variable to split the time into hours and mins
		IFS=':' read -ra TIME <<< ${3}
		
		# set the hour and min global variables
		HOUR=${TIME[0]}
		MIN=${TIME[1]}
	
	else
		# end the script as the format is not correct
		err "time format must be: [0-9]+:[0-9]+. Not "${2}.""
		print_usage
	fi

	# check for an invalid hour portion of the time stamp
	if [ "$HOUR" -gt 23 ]; then
		err " the time cannnot be above 23 hours."
		print_usage
	# check for an invalid hour portion of the time stamp
	elif [ "$HOUR" -lt 0 ]; then
		err " the time cannnot be below 0 hours."
		print_usage
	# check for an invalid min portion of the time stamp
	elif [ "$MIN" -lt 0 ]; then
		err "the minue must be between 0 and 59 minutes."
		print_usage
	#  check for an invalid min portion of the time stamp
	elif [ "$MIN" -gt 59 ]; then
		err "the time must be between 0 and 59 minutes."
		print_usage
	fi
	
	# check if the user is root (different home directory)
	if [ $USER == "root" ]; then
		# Create the backup directory for the new backup
		(mkdir /${USER}/automatedBackups 2> /dev/null)
		# Clear the directory and add a new backup once per day at the given mins and hours
		(crontab -l 2>/dev/null; echo "${MIN} ${HOUR} ${2} * * rm -rf /${USER}/automatedBackups/*; tar -czf /${USER}/automatedBackups/${USER}_${HOUR}_${MIN}.tar.gz /${USER}/ ") | crontab -	
	else
		# Create the backup directory for the new backup
		(mkdir /home/${USER}/automatedBackups 2> /dev/null)
		# Clear the directory and add a new backup once per day at the given mins and hours
		(crontab -l 2>/dev/null; echo "${MIN} ${HOUR} ${2} * * rm -rf /home/${USER}/automatedBackups/*; tar -czf  /home/${USER}/automatedBackups/${USER}_${HOUR}_${MIN}.tar.gz  /home/${USER}/ ") | crontab -
	fi
	
}




# Example Use Case: 
# ./backup.sh yearly 1/12 13:00
yearly() {
	# we need exactly three args after the filepath
	if  [ "$#" != 4 ]; then
		err "Must include only two arguments for the daily option, not "$#" arguments"		
		print_usage
	fi


	# ensure that the second arg matches a time
	if echo ${3} | grep -q -E  "[0-9]+:/[0-9]+"; then
		# Using the internal field seperator (IFS) variable to split the time into hours and mins
		IFS=':' read -ra DATE <<< ${3}
		
		# set the hour and min global variables
		MONTH=${DATE[0]}
		DAY=${DATE[1]}
	
	else
		# end the script as the format is not correct
		err "time format must be: [0-9]+:[0-9]+. Not "${2}.""
		print_usage
	fi
	
	# check for an invalid day portion of the time stamp
	if [ "$DAY" -gt 31 ]; then
		err " the time cannnot be above 23 hours."
		print_usage
	# check for an invalid day portion of the time stamp
	elif [ "$DAY" -lt 0 ]; then
		err " the time cannnot be below 0 hours."
		print_usage
	# check for an invalid month portion of the time stamp
	elif [ "$MONTH" -lt 0 ]; then
		err "the minue must be between 0 and 59 minutes."
		print_usage
	#  check for an invalid month portion of the time stamp
	elif [ "$MONTH" -gt 12 ]; then
		err "the time must be between 0 and 59 minutes."
		print_usage
	fi
	
	# ensure that the second arg matches a time
	if echo ${4} | grep -q -E  "[0-9]+:[0-9]+"; then
		# Using the internal field seperator (IFS) variable to split the time into hours and mins
		IFS=':' read -ra TIME <<< ${4}
		
		# set the hour and min global variables
		HOUR=${TIME[0]}
		MIN=${TIME[1]}
	
	else
		# end the script as the format is not correct
		err "time format must be: [0-9]+:[0-9]+. Not "${2}.""
		print_usage
	fi

	# check for an invalid hour portion of the time stamp
	if [ "$HOUR" -gt 23 ]; then
		err " the time cannnot be above 23 hours."
		print_usage
	# check for an invalid hour portion of the time stamp
	elif [ "$HOUR" -lt 0 ]; then
		err " the time cannnot be below 0 hours."
		print_usage
	# check for an invalid min portion of the time stamp
	elif [ "$MIN" -lt 0 ]; then
		err "the minue must be between 0 and 59 minutes."
		print_usage
	#  check for an invalid min portion of the time stamp
	elif [ "$MIN" -gt 59 ]; then
		err "the time must be between 0 and 59 minutes."
		print_usage
	fi
	
	# check if the user is root (different home directory)
	if [ $USER == "root" ]; then
		# Create the backup directory for the new backup
		(mkdir /${USER}/automatedBackups 2> /dev/null)
		# Clear the directory and add a new backup once per day at the given mins and hours
		(crontab -l 2>/dev/null; echo "${MIN} ${HOUR} ${DAY} ${MONTH} * rm -rf /${USER}/automatedBackups/*; tar -czf /${USER}/automatedBackups/${USER}_${HOUR}_${MIN}.tar.gz /${USER}/ ") | crontab -	
	else
		# Create the backup directory for the new backup
		(mkdir /home/${USER}/automatedBackups 2> /dev/null)
		# Clear the directory and add a new backup once per day at the given mins and hours
		(crontab -l 2>/dev/null; echo "${MIN} ${HOUR} ${DAY} ${MONTH} * rm -rf /home/${USER}/automatedBackups/*; tar -czf  /home/${USER}/automatedBackups/${USER}_${HOUR}_${MIN}.tar.gz  /home/${USER}/ ") | crontab -
	fi
}

main() {
	parse_arguments "$@"
	if $DAILY; then
		daily "$@"
	elif $WEEKLY; then
 		weekly "$@"
 	elif $MONTHLY; then
 		monthly "$@"
	elif $YEARLY; then
		yearly "$@"
 	fi
	exit 0
}



# Run the script
main $*