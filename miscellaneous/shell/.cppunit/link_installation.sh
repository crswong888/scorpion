#!/bin/bash

include=/usr/include
libs=/usr/lib/x86_64-linux-gnu

sudo --validate
mkdir -p include
sudo ln -sf $include/cppunit include/cppunit
sudo ln -sf $libs libs
