#!/bin/sh
# Monitor disk usage and send notification mail on exceeding
# Copyright 2013 Clemens Tietze
# Released under the MIT and GPL Licenses.

# limit of allowed disk usage
MAX_USAGE=$1
# reciever of email notification
MAIL_TO=$2

# validate arguments
if [ "$MAX_USAGE" = "" ]; then
	echo "Error: maximum usage specified."
fi
if [ "$MAIL_TO" = "" ]; then
	echo "Error: No reciever address specified."
fi
if [ "$MAX_USAGE" = "" ] || [ "$MAIL_TO" = "" ]; then
	echo ""
	echo "Please correct the errors above and try again."
	echo "Usage e.g. $ diskalert.sh 95 foo@bar"
	echo "End."
	echo ""
	exit 0
fi
# /validation
df -H | awk 'NR > 1{ print $5 " " $1 }' | while read output;
do
  used=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  partition=$(echo $output | awk '{ print $2 }' )
  if [ $used -ge $MAX_USAGE ]; then
    echo "Disk usage on partition \"$partition ($used%)\" located on $(hostname) has exceeded the maximum usage of '$MAX_USAGE
%' at $(date)" |
     mail -s "Alert: Almost out of disk space $used%" $MAIL_TO
  fi
done
