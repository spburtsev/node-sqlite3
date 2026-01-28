#!/bin/bash

CC=xlclang
CXX=xlclang++

LDFLAGS="-q64 -Wl,DLL"
BINDING_DIR="build/Release"

echo "=== Cleaning previous builds ==="
rm -rf build
rm -rf "$BINDING_DIR"

# --- Run node-gyp configure and compile (link will fail, that's expected) ---
echo "=== Running node-gyp rebuild ==="
npx node-gyp rebuild --verbose || true

if [ ! -f "build/Release/obj.target/node_sqlite3/src/database.o" ]; then
    echo "ERROR: Compilation failed - .o files not found"
    exit 1
fi

echo "=== Compilation succeeded, manually linking ==="

cd build/Release/obj.target

xlclang++ -q64 \
  -Wl,DLL \
  -o node_sqlite3.so \
  node_sqlite3/src/backup.o \
  node_sqlite3/src/database.o \
  node_sqlite3/src/node_sqlite3.o \
  node_sqlite3/src/statement.o \
  node_modules/node-addon-api/nothing.a \
  deps/sqlite3.a \
  "$NODE_LIB"

mv node_sqlite3.so node_sqlite3.node
extattr +p node_sqlite3.node
chmod +x node_sqlite3.node

cd ../../..

echo "=== Setting up binding directory ==="
mkdir -p "$BINDING_DIR"
cp build/Release/obj.target/node_sqlite3.node "$BINDING_DIR/"
extattr +p "$BINDING_DIR/node_sqlite3.node"
chmod +x "$BINDING_DIR/node_sqlite3.node"

npm pack