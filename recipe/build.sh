#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    # If Mac OSX then set sysroot flag
    export CFLAGS="-isysroot ${CONDA_BUILD_SYSROOT} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} ${CFLAGS}"
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

cp -r ${RECIPE_DIR}/cmake/* .

# Build libf2c libraries
cmake -S . \
  -B Release \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  ${CMAKE_ARGS}

cmake --build Release --target=install --parallel ${CPU_COUNT:-2}
