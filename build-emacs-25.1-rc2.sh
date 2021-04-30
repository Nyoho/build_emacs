mkdir -p ~/Desktop/build_emacs
cd ~/Desktop/build_emacs
curl -O ftp://alpha.gnu.org/gnu/emacs/pretest/emacs-25.1-rc2.tar.xz
curl -O https://gist.githubusercontent.com/takaxp/449c2ebfb02f72b70fbba1e1a952feea/raw/97180db1774dfd06130c5054593f97dc8e01e4fc/emacs-25.0.9y-inline.patch
tar zxvf emacs-25.1-rc2.tar.xz
cd ./emacs-25.1
patch -p1 < ../emacs-25.0.9y-inline.patch
./autogen.sh
./configure --without-x --with-ns --with-modules
make bootstrap "-j$(sysctl hw.ncpu | awk '{ print $2 }')"
make install "-j$(sysctl hw.ncpu | awk '{ print $2 }')"
cd ./nextstep
open .
