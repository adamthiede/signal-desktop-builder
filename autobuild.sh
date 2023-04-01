#!/bin/bash
# An attempt at a cron job to auto build this thing
# get latest signal version that isn't beta
deps(){
	dep_packages="jq curl"
	sudo apt -qq install $dep_packages
}

#deps

# get latest non-beta release version from github API
latest_ver=$(curl -s https://api.github.com/repos/signalapp/signal-desktop/releases|jq -r .[].name|grep -v beta|head -n1)
# make it an array, starting after the 'v'
version="${latest_ver:1}"
echo $version
sleep 3
readarray -d . -t vers <<< ${version}
# branch is major.minor.x
branch="${vers[0]}.${vers[1]}.x"
./update-node $branch
# replace the clone line in Dockerfile with the new branch
sed -e "s,RUN git clone https://github.com/signalapp/Signal-Desktop.*$,RUN git clone https://github.com/signalapp/Signal-Desktop -b $branch," -i Dockerfile
# replace the VERSION variable in the CI manifests
sed -e "s,VERSION: .*$,VERSION: \"$version\"," -i .github/workflows/build.yml
sed -e "s,VERSION: .*$,VERSION: \"$version\"," -i .build.yml
sed -e "s,VERSION: .*$,VERSION: \"$version\"," -i .gitlab-ci.yml
dt=$(date --iso-8601)
sed -e "s,<release version.*,<release version=\"${latest_ver:1}\" date=\"$dt\"/>," -i org.signal.Signal.metainfo.xml

git commit -am "Autobuild for $branch"
