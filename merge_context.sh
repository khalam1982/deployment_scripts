#!/bin/bash

giturl="${2}/vms"
git clone $giturl/vms_context_properties.git 2>&1 2>/dev/null
git clone $giturl/vms_context.git 2>&1 2>/dev/null

key=keystore/$1

case "$1" in
	Dev1)
		Env=DOCVLAPPX037
		Context_Properties="vms_context_properties/vms_context_dev1.properties"
		Context_XML="vms_context/context_Dev1.xml"
		Tomcat_Home="/opt/tomcat"
		;;
	Test1)
		Env=WYCVLAPPX050
		Context_Properties="vms_context_properties/vms_context_test1.properties"
		Context_XML="vms_context/context_Test1.xml"
		Tomcat_Home="/opt/tomcat"
		;;
	Test2)
		Env=DOCVLAPPX036
		Context_Properties="vms_context_properties/vms_context_test2.properties"
		Context_XML="vms_context/context_Test2.xml"
		Tomcat_Home="/opt/tomcat"
		;;
	Test3)
		Env=WYCVLAPPX051
		Context_Properties="vms_context_properties/vms_context_test3.properties"
		Context_XML="vms_context/context_Test3.xml"
		Tomcat_Home="/opt/tomcat"
		;;
	Test5)
		Env=WYCVLAPPX083
		Context_Properties="vms_context_properties/vms_context_test5.properties"
		Context_XML="vms_context/context_Test5.xml"
		Tomcat_Home="/opt/tomcat"
		;;

	Pre-Prod1)
		Env=WYCVLAPPH003
		Context_Properties="vms_context_properties/vms_context_pre_prod1.properties"
		Context_XML="vms_context/context_Pre-Prod1.xml"
		Tomcat_Home="/opt/tomcat"
		;;
	Pre-Prod2)
		Env=DOCVLAPPH003
		Context_Properties="vms_context_properties/vms_context_pre_prod2.properties"
		Context_XML="vms_context/context_Pre-Prod2.xml"
		Tomcat_Home="/opt/tomcat"
		;;
	Prod1)
		Env=DOCVLAPPH002
		Context_Properties="vms_context_properties/vms_context_prod1.properties"
		Context_XML="vms_context/context_Prod1.xml"
		Tomcat_Home="/opt/tomcat"
		;;
	Prod2)
		Env=WYCVLAPPH002
		Context_Properties="vms_context_properties/vms_context_prod2.properties"
		Context_XML="vms_context/context_Prod2.xml"
		Tomcat_Home="/opt/tomcat"
		;;
	*)
		 Env="NULL"
	;;
esac

old_IFS=$IFS
IFS=$'\n'

for line in $(cat $Context_Properties)
do
	Key=$(echo $line | cut -d "=" -f1)
	Value=$(echo $line | cut -d "=" -f2)
	sed -i "s/$Key/$Value/g" $Context_XML
done

IFS=$old_IFS

dos2unix -q $Context_XML

cp $Context_XML context.xml

# Create dynamic script apply_context_xml.sh
cat <<EOF > apply_context_xml.sh
#!/bin/bash

# This script is automatically generated as part of copy context.xml script.


cp $Tomcat_Home/conf/context.xml $Tomcat_Home/conf/context.xml.bkp 
cp $Tomcat_Home/tmp_files/context.xml $Tomcat_Home/conf/context.xml
if [ \$? -eq 0 ]
then
echo "File context.xml copied successfully"
else
echo "File context.xml copy failed"
fi
chmod 770 $Tomcat_Home/conf/context.xml
EOF

# Copy both apply_context_xml.sh and context.xml to target server
scp -q -i $key apply_context_xml.sh tomcat@${Env}:${Tomcat_Home}/tmp_files/
scp -q -i $key context.xml tomcat@${Env}:${Tomcat_Home}/tmp_files/

# 2. Copy context.xml
if [ $? -eq 0 ]; then
	# Execute apply_context_xml.sh on target server
	ssh -q -i $key tomcat@${Env} ${Tomcat_Home}/tmp_files/apply_context_xml.sh
else
	echo "File context.xml copy failed to target server"
	exit 1
fi

cd ..
rm -fr $wks/vms_context_properties
rm -fr $wks/vms_context