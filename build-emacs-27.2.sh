#!/bin/sh

# VERSION=27.1-rc2
VERSION=27.2
BASE_VERSION=27.2
TARBALL=emacs-$VERSION.tar.xz
TARBALL_URL=http://ftpmirror.gnu.org/emacs/$TARBALL
# TARBALL_URL=https://alpha.gnu.org/gnu/emacs/pretest/$TARBALL

BUILDDIR=/tmp/build_emacs
ARCHIVEDIR=/tmp/emacs_archives
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

if [[ ! -f $ARCHIVEDIR/$TARBALL ]]; then
    echo Download the tarball.
    curl -LO $TARBALL_URL
else
    echo Resume downloading the tarball $TARBALL from $TARBALL_URL
    curl --location $TARBALL_URL \
         --continue-at - --output $TARBALL
fi

git clone --depth 1 https://github.com/takaxp/ns-inline-patch.git

cd $BUILDDIR

tar xvf $ARCHIVEDIR/$TARBALL
cd emacs-$BASE_VERSION
patch -p1 < $ARCHIVEDIR/ns-inline-patch/emacs-27.1-inline.patch

if [ $? -ne 0 ]; then echo "FAILED"; exit 1; fi
sleep 5
./autogen.sh
./configure CC=clang --without-x --with-ns \
            --with-modules --with-rsvg --with-imagemagick \
            --with-json=yes \
            --without-pop --with-mailutils
make bootstrap "-j$(sysctl hw.ncpu | awk '{ print $2 }')"
make install "-j$(sysctl hw.ncpu | awk '{ print $2 }')"
cd ./nextstep
open .
