#!/bin/bash

BUILD_VERSION=`cat ANKI_VERSION`

BUILD_ARGS_TERM="-it"
if [[ ${NO_TTY} == "1" ]]; then
	BUILD_ARGS_TERM="-t"
fi

if [ "$PRODorOSKR" = "dev" ]; then
    export BUILD_TYPE=d
elif [ "$PRODorOSKR" = "oskr" ]; then
    export BUILD_TYPE=oskr
else
    export BUILD_TYPE=""
fi

docker build --build-arg UID=$(id -u $USER) --build-arg GID=$(id -g $USER) -t victor-anki-adder build/ -f build/Dockerfile-victor

docker run ${BUILD_ARGS_TERM} \
	-v "$(pwd):/home/build/vicos-oelinux" \
	victor-anki-adder bash -c "cd ~/vicos-oelinux && ./build/deps.sh"

docker run ${BUILD_ARGS_TERM} \
    -v "$(pwd):/home/build/vicos-oelinux" \
    -v "$(pwd)/anki-deps:/home/build/.anki" \
    -v "$(pwd)/build/cache/ccache:/home/build/.ccache" \
    victor-anki-adder bash -c "cd ~/vicos-oelinux/anki/victor && ./wire/build-oe.sh"

cd anki/victor
./project/victor/scripts/stage.sh -c Release -b
cd ../../
cd build/dvcbs-reloaded
mkdir mounted/
mv ../../_build/vicos-$BUILD_VERSION.$BUILD_INCREMENT*.ota mounted/
echo "This next command might ask for sudo"
sudo ./dvcbs-reloaded.sh -m
cd mounted/edits
echo "removing anki"
sudo rm -rf anki/
echo "Sudo may be needed again to move new anki folder"
sudo mv ../../../../anki/victor/_build/staging/Release/anki/ anki/
echo "Making /anki executable"
sudo chmod -R +rwx anki/
cd ../../
sudo ./dvcbs-reloaded.sh -bt $BUILD_VERSION $BUILD_INCREMENT $PRODorOSKR
mv mounted/*.ota mounted/vicos-$BUILD_VERSION.$BUILD_INCREMENT$BUILD_TYPE.ota
mv mounted/vicos-$BUILD_VERSION.$BUILD_INCREMENT$BUILD_TYPE.ota ../../_build/