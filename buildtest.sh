echo "Hi Afsha "
giturl="$1"
gituser="$2"
git clone $giturl
cd vendmanagementsystem
mvn clean install
echo "excuted by $gituser"