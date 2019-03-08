#!/bin/bash
cd `dirname $0 && pwd`
MY_REPO=jiapinai

hub_tag_exist(){
	if [ -f "cache/${MY_REPO}.$1.$2" ]; then
		echo 1
	fi 
    curl -s https://hub.docker.com/v2/repositories/${MY_REPO}/$1/tags/$2/ | jq -r .name
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
	if [ "$( hub_tag_exist $img_name $tag )" == null ]; then
		echo "$repo:$tag => $target:$tag"
		image_pull "$repo:$tag" "$target:$tag"
	fi
	echo "cache/${MY_REPO}.$img_name.$tag" > "cache/${MY_REPO}.$img_name.$tag"
}

main(){
	pwd
	ls -al
	pedingList=(`xargs -n1 < images`)
	echo "pedingList COUNT: ${#pedingList[@]}"
	for repo in ${pedingList[@]};do
	    image_prepare $repo
	done
}

main