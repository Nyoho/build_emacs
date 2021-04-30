#!/bin/sh

BUILDDIR=/tmp/build_emacs
ARCHIVEDIR=/tmp/emacs_archives
VERSION=26.3
rm -rf $BUILDDIR
mkdir -p $BUILDDIR
mkdir -p $ARCHIVEDIR

# LIBXML2 for Catalina
MACSDK=`xcrun --show-sdk-path`
export LIBXML2_CFLAGS="-I${MACSDK}/usr/include/libxml2"
export LIBXML2_LIBS="-lxml2"
export PATH="/usr/local/opt/texinfo/bin:$PATH"

# brew install imagemagick@6
export PKG_CONFIG_PATH="/usr/local/opt/imagemagick@6/lib/pkgconfig"

cd $ARCHIVEDIR

if [[ ! -f $ARCHIVEDIR/emacs-$VERSION.tar.xz ]]; then
    echo Download a tarball.
    curl -LO http://ftpmirror.gnu.org/emacs/emacs-$VERSION.tar.xz
else
    curl --location http://ftpmirror.gnu.org/emacs/emacs-$VERSION.tar.xz \
         --continue-at - --output emacs-$VERSION.tar.xz
fi

git clone --depth 1 https://github.com/takaxp/ns-inline-patch.git

cd $BUILDDIR

tar xvf $ARCHIVEDIR/emacs-$VERSION.tar.xz
cd emacs-$VERSION
patch -p1 < $ARCHIVEDIR/ns-inline-patch/emacs-25.2-inline.patch
patch -p1 < $ARCHIVEDIR/ns-inline-patch/fix-emacs26.3-unexmacosx.c.patch
if [ $? -ne 0 ]; then echo "FAILED"; exit 1; fi
sleep 5
./autogen.sh
./configure CC=clang --without-x --with-ns --with-modules --with-rsvg --with-imagemagick --without-pop --with-mailutils
make bootstrap "-j$(sysctl hw.ncpu | awk '{ print $2 }')"
make install "-j$(sysctl hw.ncpu | awk '{ print $2 }')"
cd ./nextstep
open .
