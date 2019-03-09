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
	docker push "$2"
	docker rmi "$1"
	docker rmi "$2"
}

image_prepare(){
	repo=`echo "$1" | awk -F':' '{print \$1}'`
	tag=`echo "$1" | awk -F':' '{print \$2}'`
	img_name=$(echo "$repo" | sed 's/\//./g' )
	target="$MY_REPO/$img_name"
	exists=$( hub_tag_exist "$img_name" "$tag" )
	echo "$repo => $img_name $tag $exists"
	if [ null == "$exists" ]; then
		echo "$repo:$tag => $target:$tag"
		image_pull "$repo:$tag" "$target:$tag"
	else
		echo "ignored [$exists] $1"
	fi
	echo "cache/${MY_REPO}.$img_name.$tag" > "cache/${MY_REPO}.$img_name.$tag"
}

main(){
	pwd
	ls -al
	# pedingList=(`xargs -n1 < images`)
	pedingList=(`cat image/images  | sort -r -u| xargs -n1`) # desc order
	echo "pedingList COUNT: ${#pedingList[@]}"
	for repo in ${pedingList[@]};do
	    image_prepare $repo
	done
}

main