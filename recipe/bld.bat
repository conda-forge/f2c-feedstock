
mkdir %LIBRARY_PREFIX%/include
copy f2c.h %LIBRARY_PREFIX%/include
mkdir %LIBRARY_PREFIX%/include/f2c
copy f2c.h %LIBRARY_PREFIX%/include/f2c

cd src

copy makefile.vc Makefile

nmake

copy f2c %LIBRARY_PREFIX%/bin