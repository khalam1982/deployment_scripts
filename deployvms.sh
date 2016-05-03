#!/bin/bash

# Script to copy the .war file to respective environments /opt/tomcat/webapps directory.
artExtn="war"
ProjectName="$1"
artifactoryURL="$3"
artifactoryUser="$4"
artifactoryPassword="$5"
buildfilename="$ProjectName-$6-bld_$7.$artExtn"
branchname="$8"
artiURL="${artifactoryURL}/VMS/${branchname}/$buildfilename"

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


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
# Check if the packet exists and download from Artifactory
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
curl -u $artiUser:$artiPwd --output /dev/null --silent --head --fail $artiURL 

if [ "$?" = "0" ]
then
    echo "[INFO ] : Downloading $buildfilename from artifactory to `pwd`"
    wget  --user=$artiUser --password=$artiPwd -q -N $artiURL 2>&1 2>/dev/null
    echo "[INFO ] : Download completed"
else
    echo "[ERROR] : Cannot access : $artiURL"
    echo "[INFO ] : Either the Build filename is formed incorrectly or Artifactory \($2\) is down"
    exit 1
fi

# 1. Remove existing version of application
echo "Clearing existing application component and temp and work folders"
ssh -i $key tomcat@${Env} -C "rm -rf /opt/tomcat/webapps/${ProjectName}" 2>&1 2>/dev/null
ssh -i $key tomcat@${Env} -C "rm -rf /opt/tomcat/webapps/${ProjectName}.war" 2>&1 2>/dev/null
ssh -i $key tomcat@${Env} -C "rm -rf /opt/tomcat/temp/*" 2>&1 2>/dev/null
ssh -i $key tomcat@${Env} -C "rm -rf /opt/tomcat/work/*" 2>&1 2>/dev/null

# 2. Copy the latest application war 
echo "Deploying latest version of the application component"
scp -i $key $buildfilename tomcat@${Env}:/opt/tomcat/webapps/${ProjectName}.war 2>&1 2>/dev/null
ssh -i $key tomcat@${Env}  -C "chmod -R 770 /opt/tomcat/webapps/${ProjectName}.war" 2>&1 2>/dev/null






