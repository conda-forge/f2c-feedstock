#!/bin/bash

# Build libf2c.a and libf2c.so libraries
cd libf2c

# Patch arithchk.c to make it compatible with the Fermi Science Tools
# (and most probably with most other software)
patch arithchk.c ${RECIPE_DIR}/patch_arithchk

# Using the makefile provided with the package
# but adding the -fPIC option to the CFLAGS
# Use the builtin compiler toolchain
sed -e's/CFLAGS = -O/CFLAGS = -O -fPIC/g' \
  -e"s;CC = cc;CC = ${CC};g" \
  -e"s;ld ;${LD} ;g" \
  -e"s;ar r;${AR} r;g" \
  -e"s/\$(CC) \$(CFLAGS) -DNO_FPINIT arithchk.c/cc \$(CFLAGS) -DNO_FPINIT arithchk.c/g" \
	-e"s/\$(CC) -DNO_LONG_LONG/cc -DNO_LONG_LONG/" \
makefile.u > Makefile

# If this is a mac, allow the main symbol to be undefined in the shared library
if [ "$(uname)" == "Darwin" ]; then
  sed -i '' \
  -e "s;\$(CC) -shared;\$(CC) -shared \$(CFLAGS) -Wl,-U,_MAIN__ -Wl,-rpath,${PREFIX}/lib ;g"\
  Makefile
fi

make hadd
make all

# Make sure ${PREFIX}/ dirs exist, they might not since
# this package does not depend on anything
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include/f2c

# Install the header and static library
make install libdir=${PREFIX}/lib \
  LIBDIR=${PREFIX}/lib \
  includedir=${PREFIX}/include/f2c \
  INCDIR=${PREFIX}/include/f2c

# Some programs need f2c.h to be in ${PREFIX}/include, some in ${PREFIX}/include/f2c
# "make install" above does not reliably install it, so we need to do it manually.
cp f2c.h ${PREFIX}/include/f2c.h
cp f2c.h ${PREFIX}/include/f2c/f2c.h

# Make the shared library explicity. It's neither part of the "all" target, nor the
# "install" target.
make libf2c.so
cp libf2c.so ${PREFIX}/lib/libf2c.so

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
