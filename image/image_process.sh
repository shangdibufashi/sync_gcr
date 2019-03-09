#!/bin/bash
cd `dirname $0 && pwd`
MY_REPO=jiapinai

hub_tag_exist(){
	if [ -f "cache/${MY_REPO}.$1.$2" ]; then
		echo 1
	else
	    curl -s https://hub.docker.com/v2/repositories/${MY_REPO}/$1/tags/$2/ | jq -r .name 
	fi 
}

image_pull(){
	docker pull "$1" > pull.log
	docker tag "$1" "$2"
	docker push "$2" > pull.log
	docker rmi "$1" > pull.log
	docker rmi "$2" > pull.log
}

image_prepare(){
	repo=`echo "$1" | awk -F':' '{print \$1}'`
	tag=`echo "$1" | awk -F':' '{print \$2}'`
	img_name=$(echo "$repo" | sed 's/\//./g' )
	target="$MY_REPO/$img_name"
	exists=$( hub_tag_exist "$img_name" "$tag" )
	# echo "$repo => $img_name $tag $exists"
	DATE=`date '+%Y-%m-%d %H:%M:%S'`
	if [ null == "$exists" ]; then
		echo "$DATE $2 $repo:$tag => $target:$tag"
		image_pull "$repo:$tag" "$target:$tag"
	else
		echo "$DATE $2 ignored [$exists] $1"
	fi
	FILE="cache/${MY_REPO}.$img_name.$tag"
	[ ! -f "$FILE" ] && echo "$DATE cache/${MY_REPO}.$img_name.$tag" > "$FILE"
}

main(){
	pwd
	ls -al
	# pedingList=(`xargs -n1 < images`)
	pedingList=(`cat images  | sort -r -u| xargs -n1`) # desc order
	echo "pedingList COUNT: ${#pedingList[@]}"
	TOTAL=${#pedingList[@]}
	N=1
	for repo in ${pedingList[@]};do
		N=$((N+1))
	  image_prepare $repo "$N/$TOTAL"
	done
}

main