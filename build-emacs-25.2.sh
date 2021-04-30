#!/bin/sh

BUILDDIR=/tmp/build_emacs
VERSION=25.2
rm -rf $BUILDDIR
mkdir -p $BUILDDIR
cd $BUILDDIR
curl -LO http://ftpmirror.gnu.org/emacs/emacs-$VERSION.tar.xz
curl -LO https://gist.githubusercontent.com/takaxp/3314a153f6d02d82ef1833638d338ecf/raw/156aaa50dc028ebb731521abaf423e751fd080de/emacs-25.2-inline.patch
tar zxvf emacs-$VERSION.tar.xz
cd ./emacs-$VERSION
patch -p1 < ../emacs-$VERSION-inline.patch
sleep 5
./autogen.sh
./configure --without-x --with-ns --with-modules
# ./configure --without-x --with-ns --with-modules --without-xml2 --with-librsvg
make bootstrap "-j$(sysctl hw.ncpu | awk '{ print $2 }')"
make install "-j$(sysctl hw.ncpu | awk '{ print $2 }')"
cd ./nextstep
open .

