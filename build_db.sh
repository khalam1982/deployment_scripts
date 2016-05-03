foldername="$1"
artifactoryURL="$2"
artifactoryUser="$3"
artifactoryPassword="$4"
release_number="$5"
giturl="${6}/vms/vms_db.git"
build_number="${7}"

wks=`pwd`

git clone $giturl 2>&1 2>/dev/null
cd vms_db
tarfilename="VMSDB_${foldername}_${release_number}_${build_number}.tar"
tar cf $tarfilename $foldername
ArtifactoryFolder="$artifactoryURL/VMS/Master/$tarfilename"
curl -i -X PUT -u $artifactoryUser:$artifactoryPassword -T "$tarfilename" "$ArtifactoryFolder"
if [ "$?" = "0" ]; then	
    echo "Successfully uploaded release package to artifactory"
else
	echo "Unexpected error found during archival of artefacts"
fi	
cd ..
rm -fr $wks/vms_db