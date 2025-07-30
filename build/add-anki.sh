#!/bin/bash

BUILD_VERSION="cat ANKI_VERSION"

BUILD_ARGS_TERM="-it"
if [[ ${NO_TTY} == "1" ]]; then
	BUILD_ARGS_TERM="-t"
fi

docker build --build-arg UID=$(id -u $USER) --build-arg GID=$(id -g $USER) -t victor-builder build/ -f build/Dockerfile-victor

docker run ${BUILD_ARGS_TERM} \
	-v "$(pwd):/home/build/vicos-oelinux" \
	victor-builder bash -c "cd ~/vicos-oelinux && ./build/deps.sh"

docker run ${BUILD_ARGS_TERM} \
    -v "$(pwd):/home/build/vicos-oelinux" \
    -v "$(pwd)/anki-deps:/home/build/.anki" \
    -v "$(pwd)/build/cache/ccache:/home/build/.ccache" \
    victor-builder bash -c "cd ~/vicos-oelinux/anki/victor && ./project/victor/scripts/victor_build_release.sh -x /usr/bin/cmake"

#./wire/build-d.sh
#./project/victor/scripts/stage.sh -c Release -b
#cd ../../
#cd build/dvcbs-reloaded
#mkdir mounted/
#mv ../../_build/vicos-$BUILD_VERSION.$BUILD_INCREMENT.ota mounted/