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
export PATH="/opt/homebrew/opt/texinfo/bin:$PATH"

# brew install tree-sitter

# brew install imagemagick@6

# set -gx LDFLAGS "-L/opt/homebrew/opt/imagemagick@6/lib"
# set -gx CPPFLAGS "-I/opt/homebrew/opt/imagemagick@6/include"

export PKG_CONFIG_PATH="/opt/homebrew/opt/imagemagick@6/lib/pkgconfig:/opt/homebrew/lib/pkgconfig:/opt/homebrew/opt/libxau/lib/pkgconfig:/opt/homebrew/opt/xorgproto/share/pkgconfig:/opt/homebrew/opt/libxdmcp/lib/pkgconfig:/opt/homebrew/opt/libxrender/lib/pkgconfig:/opt/homebrew/opt/libx11/lib/pkgconfig:/opt/homebrew/opt/libxext/lib/pkgconfig:/opt/homebrew/opt/webp/lib/pkgconfig"

# for librsvg
# export RSVG_CFLAGS="-I/opt/homebrew/opt/librsvg/include/librsvg-2.0"
# export RSVG_LIBS="-L/opt/homebrew/opt/librsvg/lib -lrsvg-2 -lm"

# export CAIRO_CFLAG="-I/opt/homebrew/opt/cairo/include/cairo"
# export CAIRO_LIBS="-L/opt/homebrew/opt/cairo/lib -lcairo"

export CFLAGS="$(pkg-config --cflags glib-2.0 gdk-pixbuf-2.0 librsvg-2.0 gio-2.0 gobject-2.0 cairo libwebp)"
export   LIBS="$(pkg-config --libs   glib-2.0 gdk-pixbuf-2.0 librsvg-2.0 gio-2.0 gobject-2.0 cairo libwebp)"
export LIBRARY_PATH="$(brew --prefix libgccjit)/lib/gcc/current:${LIBRARY_PATH:-}"

# export CFLAGS="-I/opt/homebrew/opt/glib/include/glib-2.0 -I/opt/homebrew/opt/gettext/include -I/opt/homebrew/opt/pcre/include -I/opt/homebrew/opt/glib/lib/glib-2.0/include -I/opt/homebrew/opt/cairo/include/cairo -I/opt/homebrew/opt/gdk-pixbuf/include/gdk-pixbuf-2.0"
# export LIBS="-L/opt/homebrew/opt/glib/lib -lm -L/opt/homebrew/opt/gettext/lib -lglib-2.0 -lintl -Wl,-framework,CoreFoundation -Wl,-framework,Carbon -Wl,-framework,Foundation -Wl,-framework,AppKit -lgio-2.0 -lgobject-2.0 -liconv -lm -L/opt/homebrew/opt/gdk-pixbuf/lib -lgdk_pixbuf-2.0"

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
    git clone --depth 1 https://github.com/emacs-mirror/emacs.git
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
            --with-native-compilation=aot \
            --with-modules \
            --with-imagemagick \
            --with-xwidgets \
            --without-pop --with-mailutils
make bootstrap "-j$(sysctl hw.ncpu | awk '{ print $2 }')"
make install "-j$(sysctl hw.ncpu | awk '{ print $2 }')"
cd ./nextstep
open .
