#!/bin/bash
# Establish ssh tunnel, execute a command or script and close the ssh tunnel
# Copyright 2013 Clemens Tietze
# Released under the MIT and GPL Licenses.
# 
# params
# (1) number local port
# (2) number remote address
# (3) number remote port
# (4) string ssh username
# (5) string command or scriptname, wrap in '' if passing arguments is required
#
# usage:
# $ e.g. sshScriptWrapper.sh 3307 127.0.0.1 3306 username 'command/script [arg1 arg2...]'

# declare local port
PORT=$1
# declare remote host <IP|HOSTNAME>
REMOTEHOST=$2
# declare remote port
REMOTEPORT=$3
# declare ssh username
SSH_USER=$4
# command to execute during established ssh connection
WRAPPED_SCRIPT=$5

# vars
scriptName="$(basename $0)";
scriptPid=0

# functions

# check if a process with this scriptname still exists in process list
function checkScriptExecution(){
	scriptPid=`ps afx | grep -v "grep" | grep $scriptName | awk '{print $1; exit}'`
}

# return pid of the ssh matching ssh process
function getSshTunnelPid(){
	
	sshPid=`ps ax | grep "[s]sh -fNg -L $PORT:$REMOTEHOST:$REMOTEPORT $SSH_USER@$REMOTEHOST" | awk '{print $1}'`;
	
	ts=`date "+%Y-%m-%d %H:%M:%S"`;
	echo "$scriptName [$ts] $FUNCNAME [$PORT:$REMOTEHOST:$REMOTEPORT $SSH_USER@$REMOTEHOST]...";
}

# open ssh tunnel in backround with given parameters
function openSshTunnel(){
	getSshTunnelPid

	if [ -z "$sshPid" ]; then
		ts=`date "+%Y-%m-%d %H:%M:%S"`;
                echo "$scriptName [$ts] $FUNCNAME: Starting ssh tunnel w/ [$PORT:$REMOTEHOST:$REMOTEPORT $SSH_USER@$REMOTEHOST]...";
		ssh -fNg -L $PORT:$REMOTEHOST:$REMOTEPORT $SSH_USER@$REMOTEHOST
        else
		ts=`date "+%Y-%m-%d %H:%M:%S"`;
        	echo "$scriptName [$ts] $FUNCNAME: Tunnel found w/ PID $sshPid...";
	fi;

}

# close ssh tunnel
function closeSshTunnel(){
	getSshTunnelPid
	if [ "$sshPid" > 0 ]; then
		ts=`date "+%Y-%m-%d %H:%M:%S"`;
		echo "$scriptName [$ts] $FUNCNAME: Process found, killing PID w/ $sshPid";
		kill $sshPid
	else
		ts=`date "+%Y-%m-%d %H:%M:%S"`;
		echo "$scriptName [$ts] $FUNCNAME: No tunnel found...";
	fi; 
}
# /functions

# validate arguments
if [ "$PORT" = "" ]; then
	echo "Error: No local port specified."
fi
if [ "$REMOTEPORT" = "" ]; then
	echo "Error: No remote port specified."
fi
if [ "$REMOTEHOST" = "" ]; then
	echo "Error: No remote host specified."
fi
if [ "$SSH_USER" = "" ]; then
	echo "Error: No username specified."
fi
if [ "$PORT" = "" ] || [ "$REMOTEPORT" = "" ] || [ "$REMOTEHOST" = "" ] || [ "$SSH_USER" = "" ]; then
	echo ""
	echo "Please correct the errors above and try again."
	echo "Usage e.g. $ sshScriptWrapper.sh 3307 127.0.0.1 3306 username 'script [arg1 arg2 ...]'"
	echo "End."
	echo ""
	exit 0
fi
# /validation

# script
ts=`date "+%Y-%m-%d %H:%M:%S"`;
echo "$(basename $0) [$ts] Start...";

checkScriptExecution
if [ "$scriptPid" > 0 ] && [ "$$" -ne "$scriptPid" ]; then
	ts=`date "+%Y-%m-%d %H:%M:%S"`;
	echo "$scriptName [$ts] Script still running with pid $scriptPid";
else
	openSshTunnel
	echo  `$WRAPPED_SCRIPT`
fi; 

closeSshTunnel
ts=`date "+%Y-%m-%d %H:%M:%S"`;
echo "$scriptName [$ts] ... stop." 
