#!/bin/bash
cd `dirname $0 && pwd`
git clone git@github.com:helm/charts.git

find /charts/stable/ -name '*.yaml'  | \
	xargs -n1 egrep -v '^\s+#|^\s*-' | \
	egrep -A 1  '^\s+repository:' | \
	egrep -v '^-' | \
	sed '$!N;s/\n/ /' | \
	egrep  'quay.io|gcr.io|bintray.io|elastic.co' | \
	sed 's/["#]//g' | \
	sort | \
	uniq | \
	awk '{print $2":"$4}' | \
	egrep  '\d+$' > images

