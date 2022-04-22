#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    # If Mac OSX then set sysroot flag
    export CFLAGS="-isysroot ${CONDA_BUILD_SYSROOT} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} ${CFLAGS}"
    export LDFLAGS="${LDFLAGS} -L${CONDA_BUILD_SYSROOT}/usr/lib -headerpad_max_install_names"
fi

# Build libf2c libraries
cd libf2c

# Using the makefile provided with the package but adding the environment CFLAGS to the
# declaraction. Use the builtin compiler toolchain
# cp makefile.u Makefile
sed -e"s;CFLAGS = -O -fPIC;CFLAGS = ${CFLAGS} -O -fPIC;g"  makefile.u > Makefile

cp ${RECIPE_DIR}/MAIN_stub.c .


make hadd
make all

# Make sure ${PREFIX}/ dirs exist, they might not since
# this package does not depend on anything
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include/f2c

# Install the header and static library
make install \
  libdir=${PREFIX}/lib \
  LIBDIR=${PREFIX}/lib \
  includedir=${PREFIX}/include/f2c \
  INCDIR=${PREFIX}/include/f2c

# Some programs need f2c.h to be in ${PREFIX}/include, some in ${PREFIX}/include/f2c
# "make install" above does not reliably install it, so we need to do it manually.
cp f2c.h ${PREFIX}/include/f2c.h
cp f2c.h ${PREFIX}/include/f2c/f2c.h

# Make the shared library explicity. It's neither part of the "all" target, nor the
# "install" target.
# make libf2c.so
# cp libf2c.so ${PREFIX}/lib/libf2c.so

# Now build the f2c executable
cd ../src

# Use the builtin compiler toolchain
sed -e"s;CC = cc;CC = ${CC};g" makefile.u > Makefile

make f2c

# Install the binary
mkdir -p ${PREFIX}/bin
cp f2c ${PREFIX}/bin/f2c

# Install the pkg-config file
echo "Version: ${PKG_VERSION}" >> ${RECIPE_DIR}/f2c.pc
mkdir -p ${PREFIX}/lib/pkgconfig
cp ${RECIPE_DIR}/f2c.pc ${PREFIX}/lib/pkgconfig/f2c.pc
