
mkdir %LIBRARY_PREFIX%/include
copy f2c.h %LIBRARY_PREFIX%/include
mkdir %LIBRARY_PREFIX%/include/f2c
copy f2c.h %LIBRARY_PREFIX%/include/f2c

cd src

copy makefile.vc Makefile

nmake f2c.exe

copy f2c.exe %LIBRARY_PREFIX%/bin
