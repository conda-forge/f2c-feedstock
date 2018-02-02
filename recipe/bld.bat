
mkdir %LIBRARY_PREFIX%\include
copy f2c.h %LIBRARY_PREFIX%\include
mkdir %LIBRARY_PREFIX%\include\f2c
copy f2c.h %LIBRARY_PREFIX%\include\f2c

cd src

nmake -f makefile.vc f2c.exe

copy f2c.exe %LIBRARY_PREFIX%\bin
