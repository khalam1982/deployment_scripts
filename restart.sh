#!/bin/bash

# Script to copy the .war file to respective environments /opt/tomcat/webapps directory.
action_type="$1"
pno=0

key=keystore/$2

# Environments
case "$2" in
	Dev1)
		Env=DOCVLAPPX037
		Webapps_location="/opt/tomcat/webapps"
	;;
	Test1)
		Env=WYCVLAPPX050
		Webapps_location="/opt/tomcat/webapps"
	;;
	Test2)
		Env=DOCVLAPPX036
		Webapps_location="/opt/tomcat/webapps"
	;;
	Test3)
		Env=WYCVLAPPX051
		Webapps_location="/opt/tomcat/webapps"
	;;
	Test5)
		Env=WYCVLAPPX083
		Webapps_location="/opt/tomcat/webapps"
	;;
	Pre-Prod1)
		Env=WYCVLAPPH003
		Webapps_location="/opt/tomcat/webapps"
	;;
	Pre-Prod2)
		Env=DOCVLAPPH003
		Webapps_location="/opt/tomcat/webapps"
	;;
	Prod1)
		Env=DOCVLAPPH002
		Webapps_location="/opt/tomcat/webapps"
	;;
	Prod2)
		Env=WYCVLAPPH002
		Webapps_location="/opt/tomcat/webapps"
	;;
	*)
		Env="NULL"
	;;
esac


if [ "$action_type" = "Stop" ]; then
	echo "Stopping Tomcat service on $2 ..."
	TOMCAT_PROCESS_NUM=$(ssh -i $key tomcat@${Env} -C "ps -aef | grep java | grep -v \"grep\" | wc -l" 2>&1 2>/dev/null)
	if [ $TOMCAT_PROCESS_NUM -eq 0 ]; then
		echo "Tomcat is already stopped..."
	else
		ssh -i $key tomcat@${Env} -C "sh /opt/tomcat/bin/catalina.sh stop -force" 2>&1 2>/dev/null
		sleep 30s 
		TOMCAT_PROCESS_NUM=$(ssh -i $key tomcat@${Env} -C "ps -aef | grep java | grep -v \"grep\" | wc -l" 2>&1 2>/dev/null)
		if [ $TOMCAT_PROCESS_NUM -eq 0 ]; then
			echo "Tomcat stopped successfully."
		else
			echo "Tomcat could not be stopped."
			exit 1;
		fi
	fi		
fi
if [ "$action_type" = "Start" ]; then
	echo "Attempting to start Tomcat server after the deployment"
	TOMCAT_PROCESS_NUM=$(ssh -i $key tomcat@${Env} -C "ps -aef | grep java | grep -v \"grep\" | wc -l" 2>&1 2>/dev/null)
	if [ $TOMCAT_PROCESS_NUM -eq 0 ]; then
		ssh -i $key tomcat@${Env}  -C "sh /opt/tomcat/bin/startup.sh" 2>&1 2>/dev/null
		pno=`ssh -i $key tomcat@${Env}  -C "cat /opt/tomcat/pid" 2> /dev/null`
		sleep 30s
		TOMCAT_PROCESS_NUM=$(ssh -i $key tomcat@${Env} -C "ps -aef | grep java | grep -v \"grep\" | wc -l" 2>&1 2>/dev/null)
		if [ $TOMCAT_PROCESS_NUM -eq 0 ]; then
			echo "Tomcat could not be started."
			exit 1;
		else
			echo "Tomcat started successfully and running with PID : $pno."
		fi
	else
		echo "Tomcat is already started."
	fi
fi





