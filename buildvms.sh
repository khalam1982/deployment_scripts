set +x
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Download build scripts and initiate builds process
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

projectname="$1"            # Project name in Classic notation case e.g. VMS"
artExtn="war"
artifactoryURL="$2"
artifactoryUser="$3"
artifactoryPassword="$4"
relno="$5"
publishRelease="$6"
branchname="$7"
giturl="${8}/vms/${projectname}.git"
bldno="${9}"
targetFolder="${artifactoryURL}/VMS/${branchname}"

wks=`pwd`
mkdir -p $wks/VMS
localFilePath="$wks/VMS/$projectname/target"
cd $wks/VMS
if [ ${branchname} = "Master" ]; then
	git clone $giturl 2>&1 2>/dev/null
else
	git clone -b ${branchname} $giturl 2>&1 2>/dev/null
fi	

# 1. Execute maven target
BLD=${projectname}-$relno-bld_$bldno.${artExtn}
cd $projectname
buildCmd="/d/apache-maven-3.2.5/bin/mvn clean install"
$buildCmd

# 2. Build versioning logic
mv ${localFilePath}/${projectname}*.${artExtn} ${localFilePath}/${BLD}

# 3. Publish artifacts to artifactory
which md5sum || exit $?
which sha1sum || exit $?

md5Value="`md5sum "$localFilePath/${BLD}"`"
md5Value="${md5Value:0:32}"
sha1Value="`sha1sum "$localFilePath/${BLD}"`"
sha1Value="${sha1Value:0:40}"
fileName="`basename "$localFilePath/$BLD"`"

echo $md5Value $sha1Value $localFilePath/${BLD}
if [ "$publishRelease" = "Yes" ]
then
	echo "INFO: Uploading $localFilePath to $targetFolder/$fileName"
	curl -i -X PUT -u $artifactoryUser:$artifactoryPassword \
	 -H "X-Checksum-Md5: $md5Value" \
	 -H "X-Checksum-Sha1: $sha1Value" \
	 -T "$localFilePath/$BLD" \
	 "$targetFolder/$fileName"
	if [ "$?" = "0" ]; then	
		echo "Successfully uploaded release package to artifactory"
	else
		echo "Unexpected error found during archival of artefacts"
	fi	 
fi
cd ../..
rm -fr $wks/VMS



