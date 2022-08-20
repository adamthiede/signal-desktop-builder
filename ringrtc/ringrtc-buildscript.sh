#!/bin/bash

set -x

export PATH=$(pwd)/depot_tools/:/opt/node/bin/:$PATH
cd ringrtc
mkdir -p .cargo
#cat << HEREDOC > .cargo/config.toml
#[target.aarch64-unknown-linux-gnu]
#linker = "aarch64-linux-gnu-gcc"
#HEREDOC 
echo -e '[target.aarch64-unknown-linux-gnu]\nlinker = "aarch64-linux-gnu-gcc"' > .cargo/config.toml

source ~/.cargo/env

rustup toolchain install 1.51.0
rustup default 1.51.0
rustup target add aarch64-unknown-linux-gnu
make electron PLATFORM=unix NODEJS_ARCH=arm64
# This file doesn't exist until the above has failed...
./src/webrtc/src/build/linux/sysroot_scripts/install-sysroot.py --arch=arm64
make electron PLATFORM=unix NODEJS_ARCH=arm64
cp src/node/build/linux/libringrtc-arm64.node ../..
