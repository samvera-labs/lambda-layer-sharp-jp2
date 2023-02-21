#!/bin/bash

export PKG_CONFIG_PATH=/usr/lib64/pkgconfig:/opt/lib/pkgconfig
if [[ -e ./autogen.sh ]]; then
  ./autogen.sh --prefix=/opt
  ./configure --prefix=/opt
  make install  
else
  meson setup build --prefix /opt --libdir lib
  cd build
  meson compile
  meson install
fi
