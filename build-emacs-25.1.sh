BUILDDIR=~/Desktop/build_emacs
rm -rf $BUILDDIR
mkdir -p $BUILDDIR
cd $BUILDDIR
curl -LO http://ftpmirror.gnu.org/emacs/emacs-25.1.tar.xz
curl -LO https://gist.githubusercontent.com/takaxp/f30f54663c08e257b8846cc68b37f09f/raw/bbf307d220b23ce0ccec766c3ee23852e71c80df/emacs-25.1-inline.patch
tar zxvf emacs-25.1.tar.xz
cd ./emacs-25.1
patch -p1 < ../emacs-25.1-inline.patch
./autogen.sh
./configure --without-x --with-ns --with-modules --without-xml2 --with-librsvg
make bootstrap "-j$(sysctl hw.ncpu | awk '{ print $2 }')"
make install "-j$(sysctl hw.ncpu | awk '{ print $2 }')"
cd ./nextstep
open .
