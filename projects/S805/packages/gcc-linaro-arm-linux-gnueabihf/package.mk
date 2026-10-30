# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="gcc-linaro-arm-linux-gnueabihf"
PKG_VERSION="bd8d7f5"
PKG_SHA256="af8e224a31019d4a7d27055245c7ab8fd1ba896a0326a8097fc014ccc358252c"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL="https://github.com/sdphome/$PKG_NAME-4.9-2014.09_linux/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_HOST="ccache:host"
PKG_LONGDESC="Linaro ARM GNU Linux Binary Toolchain"
PKG_TOOLCHAIN="manual"

makeinstall_host() {
  rm -rf $PKG_BUILD_DIR/share/aclocal/pkg.m4
  rm -rf $PKG_BUILD_DIR/share/doc
  mkdir -p $TOOLCHAIN/lib/gcc-linaro-arm-linux-gnueabihf/
  cp -a * $TOOLCHAIN/lib/gcc-linaro-arm-linux-gnueabihf
}
