#!/usr/bin/env bash
set -eu

export CC=ccache\ clang CFLAGS="-mmacosx-version-min=10.11"
echo "Building x86_64"
./Configure   darwin64-x86_64-cc --prefix=/usr --openssldir=/usr/lib/ssl no-ssl    no-tests no-ui-console no-unit-test  
make clean && make -j12
make DESTDIR=./${OPENSSL} install_ssldirs install_sw 

echo "Building ARM64..."
./Configure   darwin64-arm64-cc --prefix=/usr --openssldir=/usr/lib/ssl no-ssl    no-tests no-ui-console no-unit-test 
make clean && make -j12
make DESTDIR=./${OPENSSL}-arm64 install_ssldirs install_sw


XLIB=${OPENSSL}/usr/lib
ALIB=${OPENSSL}-arm64/usr/lib

echo "Making fat binaries from ${XLIB} and ${ALIB}... "

for a in $(cd  ${XLIB}; echo *.a *[0-9]*.dylib); do 
    echo -n "$a... "
    lipo -create ${XLIB}/$a ${ALIB}/$a  -output $a
    mv $a ${XLIB}/$a
done

