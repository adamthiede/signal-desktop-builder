#!/bin/bash
echo "###ci-build.sh###"
set -x
shopt -s localvar_inherit
podman build --jobs $(nproc) -t signal-desktop-image-$VERSION .
podman create --name=signal-desktop-$VERSION -it localhost/signal-desktop-image-$VERSION bash
podman start signal-desktop-$VERSION
##podman exec -it --env-file=env -w /Signal-Desktop signal-desktop-$VERSION bash -c "echo $PATH"
podman exec -it --env-file=env signal-desktop-$VERSION bash -i -c /signal-buildscript.sh
podman exec -it --env-file=env -w /Signal-Desktop signal-desktop-$VERSION npm install --non-interactive
podman exec -it --env-file=env -w /Signal-Desktop signal-desktop-$VERSION npm install --frozen-lockfile --non-interactive
podman exec -it --env-file=env -w /Signal-Desktop signal-desktop-$VERSION rm -rf ts/test-mock
podman exec -it --env-file=env -w /Signal-Desktop signal-desktop-$VERSION npm run generate
podman exec -it --env-file=env -w /Signal-Desktop signal-desktop-$VERSION npm run build:release --arm64 --linux --dir
podman exec -it --env-file=env -w /Signal-Desktop signal-desktop-$VERSION npm run build:release --arm64 --linux deb

podman exec -it --env-file=env -w /Signal-Desktop/release signal-desktop-$VERSION mv linux-arm64-unpacked signal
podman exec -it --env-file=env -w /Signal-Desktop/release signal-desktop-$VERSION tar cJvf signal-desktop_${VERSION}.tar.xz signal

podman cp signal-desktop-${VERSION}:/Signal-Desktop/release/signal-desktop_${VERSION}_arm64.deb ~/signal-desktop.deb
podman cp signal-desktop-${VERSION}:/Signal-Desktop/release/signal-desktop_${VERSION}.tar.xz ~/signal-desktop_${VERSION}.tar.xz

