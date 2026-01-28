#!/bin/bash
set -e

export CC=xlclang
export CXX=xlclang++
export LDFLAGS="-q64 -Wl,DLL"

NODE_BIN=$(which node)
NODE_DIR=$(dirname $(dirname "$NODE_BIN"))
NODE_LIB="$NODE_DIR/lib/libnode.x"