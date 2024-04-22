#!/bin/bash
export PS4='\033[0;33m$0:$LINENO [$?]+ \033[0m '
START_DIR=$(pwd)
OUTPUT_DIR=$START_DIR/out
set -ex

if [[ -d ghidra || -f ghidra.bin || -d ${OUTPUT_DIR} ]]
then
	rm -rf ${OUTPUT_DIR} ghidra ghidra.bin || true
fi
mkdir --parents ${OUTPUT_DIR}

if [ ! -d "ghidra" ]; then
    git clone https://github.com/NationalSecurityAgency/ghidra
fi

ln --symbolic ${HOME}/ghidra.bin ghidra.bin # hack

cd ${START_DIR}/ghidra
gradle --init-script gradle/support/fetchDependencies.gradle init
gradle yajswDevUnpack
gradle buildGhidra

# Tests
# Xvfb :99 -nolisten tcp & export DISPLAY=:99
# gradle unitTestReport # ~38 minutes
# gradle integrationTest # ~3 hours

cp build/dist/*.zip ${OUTPUT_DIR}
unlink ${START_DIR}/ghidra.bin

