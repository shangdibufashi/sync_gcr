#!/bin/bash
cd `dirname $0 && pwd`
echo 'helm/charts'
[ ! -d './charts' ] && echo 'git clone git@github.com:helm/charts.git' && git clone git@github.com:helm/charts.git
ls -al
find ./charts/ -name '*.yaml'  | \
	xargs -n1 egrep -v '^\s+#|^\s*-' | \
	egrep -A 1  '^\s+repository:' | \
	egrep -v '^-' | \
	sed '$!N;s/\n/ /' | \
	egrep  'quay.io|gcr.io|bintray.io|elastic.co' | \
	sed 's/["#]//g' | \
	sort | \
	uniq | \
	awk '{print $2":"$4}' | \
	egrep  '\d+$' >> images

echo 'elastic.co'
curl 'https://www.docker.elastic.co/' | \
	grep 'docker pull' | \
	sed 's/<\/[a-z0-9A-Z]*>//g' | \
	sed 's/<[a-z0-9A-Z]*>//g'| \
	awk -F'>' '{print $2}' | \
	awk '{print $3}'| \
	sort | \
	uniq >> images

cat images | sort | uniq > tmp
rm -f images
mv tmp images
