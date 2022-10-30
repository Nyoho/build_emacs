#!/bin/sh

# For ARM

VERSION=28.2
BASE_VERSION=28.2
TARBALL=emacs-$VERSION.tar.xz
TARBALL_URL=https://ftpmirror.gnu.org/emacs/$TARBALL

BUILDDIR=/tmp/build_emacs
ARCHIVEDIR=/tmp/emacs_archives
rm -rf $BUILDDIR
mkdir -p $BUILDDIR
mkdir -p $ARCHIVEDIR

# LIBXML2 for Catalina
MACSDK=`xcrun --show-sdk-path`
export LIBXML2_CFLAGS="-I${MACSDK}/usr/include/libxml2"
export LIBXML2_LIBS="-lxml2"
export PATH="/opt/homebrew/opt/texinfo/bin:$PATH"

# brew install imagemagick@6
export PKG_CONFIG_PATH="/opt/homebrew/opt/imagemagick@6/lib/pkgconfig:/opt/homebrew/lib/pkgconfig:/opt/homebrew/opt/libxau/lib/pkgconfig:/opt/homebrew/opt/xorgproto/share/pkgconfig:/opt/homebrew/opt/libxdmcp/lib/pkgconfig:/opt/homebrew/opt/libxrender/lib/pkgconfig:/opt/homebrew/opt/libx11/lib/pkgconfig:/opt/homebrew/opt/libxext/lib/pkgconfig:/opt/homebrew/opt/webp/lib/pkgconfig"

export CFLAGS="$(pkg-config --cflags glib-2.0 gdk-pixbuf-2.0 librsvg-2.0 gio-2.0 gobject-2.0 cairo)"
export   LIBS="$(pkg-config --libs   glib-2.0 gdk-pixbuf-2.0 librsvg-2.0 gio-2.0 gobject-2.0 cairo)"

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
patch -p1 < $ARCHIVEDIR/ns-inline-patch/emacs-28.1-inline.patch

if [ $? -ne 0 ]; then echo "FAILED"; exit 1; fi
sleep 5
./autogen.sh
./configure CC=clang \
            --with-ns \
            --without-x \
            --with-native-compilation \
            --with-modules \
            --with-imagemagick \
            --with-json=yes \
            --without-pop --with-mailutils
make bootstrap "-j$(sysctl hw.ncpu | awk '{ print $2 }')"
make install "-j$(sysctl hw.ncpu | awk '{ print $2 }')"
cd ./nextstep
open .
