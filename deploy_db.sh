#!/bin/bash
Deploy_Type=${1}
Env=${2}
foldername="$3"
artifactoryURL="$4"
artifactoryUser="$5"
artifactoryPassword="$6"
release_number="$7"
build_number="${8}"


filename="VMSDB_${foldername}_${release_number}_${build_number}.tar"

filename=VMSDB_$3_$4_$5.tar 
echo $filename
ArtifactoryPath="$artifactoryURL/VMS/VMS_DB"
curl -u $artifactoryUser:$artifactoryPassword --output /dev/null --silent --head --fail $ArtifactoryPath/$filename
if [ "$?" = "0" ]
then
    echo "[INFO ] : Downloading $filename from artifactory to `pwd`"
    wget  --user=$artiUser --password=$artiPwd -q -N $ArtifactoryPath/$filename
    echo "[INFO ] : Download completed"
else
    echo "[ERROR] : Cannot access : $artiURL"
    echo "[INFO ] : Either the Build tarfilename is formed incorrectly or Artifactory is down"
    exit 1
fi
mkdir -p sql_temp 
echo "Folder created"
tar xf $filename -C sql_temp && echo "tar extracted $(ls sql_temp)"
cd sql_temp/* 


# Oracle Binary PATH
Oracle_Dir="/e/oracle/product/11.2.0/client_1/bin"

# Oracle connection String

# Script to Deploy Environment in respective environments.

# Environments
case "$Env" in
	Dev1)
		DEV_DB="[VMS_SCHEMA]/@VMS_Dev"
		;;
	Test1)
		DEV_DB="[VMS_SCHEMA]/@VMS_Test1"
		;;
	Test2)
		DEV_DB="[VMS_SCHEMA]/@VMS_Test2"
		;;
	Test3)
		DEV_DB="[VMS_SCHEMA]/@VMS_Test3"
		;;
	Test5)
		DEV_DB="[VMS_SCHEMA]/@VMS_Test5"
		;;
	Pre-Prod)
		DEV_DB="[VMS_SCHEMA]/@VVCPP2"
		;;
	Prod)
		DEV_DB="[VMS_SCHEMA]/@PVCPP2"
		;;
	*)
		Env="NULL"
	;;
esac

if [ "$Deploy_Type" = "Deploy" ]
	grep -vE "^#|^$" DB_deploy_flat_file.txt > db_deploy.txt
	
	while read line
	do
		$Oracle_Dir/sqlplus $DEV_DB < $line
	done < db_deploy.txt
fi
if [ "$Deploy_Type" = "Rollback" ]
then
	for i in *rollback*.sql
	do
		$Oracle_Dir/sqlplus $DEV_DB < $i
	done
fi	
