

CUR=$(cd `dirname $0` && pwd)
echo "CUR=$CUR"
cd $CUR

# step 1. create config.tar.gz


[ -f config.tar.gz.enc ] && rm -f config.tar.gz.enc
[ -f config.tar.gz ] && rm -f config.tar.gz
cd data
[ -f config.tar.gz ] && rm -f config.tar.gz
tar czvf config.tar.gz gcloud.config.json config.json id_rsa
mv config.tar.gz ../config.tar.gz
cd ..
if [ ! -f config.tar.gz ]; then 
	echo "config.tar.gz creation failed"
	exit 1
fi
echo 'travis login && travis encrypt-file config.tar.gz --add -r jiapinai/gcr_sync' > encrypt.sh
chmod +x encrypt.sh
docker run --rm -it -v "$CUR:/root" shidaqiu/travis-cli /root/encrypt.sh
rm -f encrypt.sh
[ -f config.tar.gz ] && rm -f config.tar.gz
echo "done"
	
