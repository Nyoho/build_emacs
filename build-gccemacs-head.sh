#!/bin/sh

BUILDDIR=/tmp/build_emacs
ARCHIVEDIR=/tmp/emacs_archives
# rm -rf $BUILDDIR
mkdir -p $BUILDDIR
mkdir -p $ARCHIVEDIR

# LIBXML2 for Catalina
MACSDK=`xcrun --show-sdk-path`
export LIBXML2_CFLAGS="-I${MACSDK}/usr/include/libxml2"
export LIBXML2_LIBS="-lxml2"
export PATH="/usr/local/opt/texinfo/bin:$PATH"

# brew install imagemagick@6
export PKG_CONFIG_PATH="/usr/local/opt/imagemagick@6/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/opt/libxau/lib/pkgconfig:/usr/local/opt/xorgproto/share/pkgconfig:/usr/local/opt/libxdmcp/lib/pkgconfig:/usr/local/opt/libxrender/lib/pkgconfig:/usr/local/opt/libx11/lib/pkgconfig:/usr/local/opt/libxext/lib/pkgconfig"

# for librsvg
# export RSVG_CFLAGS="-I/usr/local/opt/librsvg/include/librsvg-2.0"
# export RSVG_LIBS="-L/usr/local/opt/librsvg/lib -lrsvg-2 -lm"

# export CAIRO_CFLAG="-I/usr/local/opt/cairo/include/cairo"
# export CAIRO_LIBS="-L/usr/local/opt/cairo/lib -lcairo"

export CFLAGS="$(pkg-config --cflags glib-2.0 gdk-pixbuf-2.0 librsvg-2.0 gio-2.0 gobject-2.0 cairo)"
export   LIBS="$(pkg-config --libs   glib-2.0 gdk-pixbuf-2.0 librsvg-2.0 gio-2.0 gobject-2.0 cairo)"
# brew install libgccjit
export LIBRARY_PATH="/usr/local/lib/gcc/11:${LIBRARY_PATH:-}"

# export CFLAGS="-I/usr/local/opt/glib/include/glib-2.0 -I/usr/local/opt/gettext/include -I/usr/local/opt/pcre/include -I/usr/local/opt/glib/lib/glib-2.0/include -I/usr/local/opt/cairo/include/cairo -I/usr/local/opt/gdk-pixbuf/include/gdk-pixbuf-2.0"
# export LIBS="-L/usr/local/opt/glib/lib -lm -L/usr/local/opt/gettext/lib -lglib-2.0 -lintl -Wl,-framework,CoreFoundation -Wl,-framework,Carbon -Wl,-framework,Foundation -Wl,-framework,AppKit -lgio-2.0 -lgobject-2.0 -liconv -lm -L/usr/local/opt/gdk-pixbuf/lib -lgdk_pixbuf-2.0"

cd $ARCHIVEDIR

# if [[ ! -f $ARCHIVEDIR/$TARBALL ]]; then
#     echo Download the tarball.
#     curl -LO $TARBALL_URL
# else
#     echo Resume downloading the tarball $TARBALL from $TARBALL_URL
#     curl --location $TARBALL_URL \
#          --continue-at - --output $TARBALL
# fi

git clone --depth 1 https://github.com/takaxp/ns-inline-patch.git

cd $BUILDDIR

if [[ ! -d emacs/.git ]]; then
    echo Cloning...
    git clone --depth 1 git://git.sv.gnu.org/emacs.git
else
    echo Git pull...
    cd emacs
    git reset --hard master
    git clean -fdx
    git pull
fi

#tar xvf $ARCHIVEDIR/$TARBALL

cd emacs
patch -p1 < $ARCHIVEDIR/ns-inline-patch/emacs-head-inline.patch

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
