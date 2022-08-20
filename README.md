# Signal Desktop Builder
This project allows building Signal Desktop for Debian 11 on ARM64.
It is currently a work in progress, with the goal of building a flatpak
which provides Signal Desktop.

Signed releases are available at https://gitlab.com/undef1/signal-desktop-builder/-/packages

## Current Status:
* [x] Signal Desktop building
* [x] libsignal-client builds
    * No longer needed, built for arm64 by Signal
* [x] zkgroup builds
    * No longer needed. Included in libsignal-client
* [x] ringrtc builds (note: this is done on the host)
    * No longer necessary as Signal are building it themselves.
* [x] flatpak
* [ ] Wayland

## Dependencies
This system requires the following:
* Docker or Podman
* qemu-user-static (Debian package)

## Usage
1. Build the docker container: `sudo docker build .`
2. Shell into the docker container: `sudo docker run -it <image> bash`
3. Run the build script: `bash /signal-buildscript.sh`
	- or `sudo docker run -it <image> bash -i -c "bash /signal-buildscript.sh"` (`-i` for interactive gets the proper $PATH, but this might not work in all automation)
4. Copy the output application from the container (from outside container): `sudo docker cp <container>:/Signal-Desktop/release/<output folder> .`
5. Copy to your Debian Arm64 device.

### Note about Docker
Docker has a concept of "images" and "containers". `docker build` will build an image, `docker run` will create a live container from that image.
The final line of the `docker build` output is the docker "image" hash that you need for `docker run`. The "container" hash will be displayed on the commandline of the container at runtime.
This "container" hash is the one which should be used with `docker cp`.

## Note about packages:
Installing packages from untrusted sources is a risk. In the case of Debian packages, 
this is giving root access to your device to the package. In flatpaks, (sandbox escapes aside)
the worst case is likely compromise of your Signal keys/messages.

Please only install packages from sources you trust and if in doubt, build from source.
Please also note that I do not verify the upstream debian package generation scripts.

## Debian Package
Debian packages are also automatically built by the build script. They are available in the container at `/Signal-Desktop/release/`.

Debian packages are also available in this repository's packages section.

## Flatpak

To create and install the flatpak:

 - Install `git`, `flatpak`, and `flatpak-builder` from your OS:
    - Mobian/Debian: `sudo apt install flatpak flatpak-builder`
    - Arch/Manjaro: `sudo pacman -Syu flatpak flatpak-builder`
    - PostmarketOS: `sudo apk add flatpak flatpak-builder`
 - `git clone https://gitlab.com/undef1/signal-desktop-builder && cd signal-desktop-builder`
 - `sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo`
 - `sudo flatpak install flathub org.electronjs.Electron2.BaseApp/aarch64/21.08 org.freedesktop.Platform/aarch64/21.08 org.freedesktop.Sdk/aarch64/21.08`
 - `mkdir builddir`
 - `flatpak-builder --user --install --force-clean ./builddir flatpak.yml`

To enable Signal to use a dark theme on GTK-based desktop environments: `sudo flatpak install adwaita-dark -y`

Signal desktop icon should appear in your desktop launcher.

Flatpak builds are available as a Flatpak Repository at https://elagost.com/flatpak built and hosted by @elagost.

## Launcher
The included `signal` shell script provides both a launcher and sandboxing with Bubblewrap.

## RingRTC
As of Signal-Desktop 5.35.0, RingRTC is being built and distributed for arm64 Linux by Signal. These steps are no-longer necessary.

## Better-sqlite3
As of 5.48.0 we are using a newer version of better-sqlite3 than upstream Signal to work around an issue.
This works fine and we will be dropping all better-sqlite3 code as soon as upstream updates.

## Updates
I recommend that you back up `~/.config/Signal` before updating. While the releases here are tested, I have had a few of them corrupt this folder in the past. If the update fails for any reason, you will need the original database to roll back.

## Distribution Support
This build system targets Mobian Bookworm. However, builds for Debian Bullseye based distributions (PureOS Byzantium) can be created by changing the Docker file to start with `FROM arm64v8/debian:bullseye`. 

Such builds will be uploaded to the packages section from time to time as `<version>_bullseye`. These builds will not work on Mobian Bookworm and vice-versa.

These Bullseye builds are untested, but should work.

## See also:
https://github.com/lsfxz/ringrtc/tree/aarch64  
https://gitlab.com/undef1/Snippets/-/snippets/2100495  
https://gitlab.com/ohfp/pinebookpro-things/-/tree/master/signal-desktop  
Flatpak based on [Flathub Sigal Desktop builds](https://github.com/flathub/org.signal.Signal/)
 - `signal-desktop.sh` https://github.com/flathub/org.signal.Signal/blob/master/signal-desktop.sh
 - `org.signal.Signal.metainfo.xml` https://github.com/flathub/org.signal.Signal/blob/master/org.signal.Signal.metainfo.xml
 - `flatpak.yml` https://github.com/flathub/org.signal.Signal/blob/master/org.signal.Signal.yaml

## Successful builds:
* 5.0.0-beta1
* 5.1.0-beta.5
* 5.5.0-beta.1 - Note: wayland currently broken on this release
* 5.8.0-beta.1
* 5.10.0-beta.1
* 5.14-beta.1
* 5.17-beta.1
* 5.21.0-beta.2 - Note: registration broken, use 5.17 then upgrade
* 5.24.0-beta.1
* 5.28.0-beta.1
* 5.30.0-beta.1
* 5.30.0
* 5.31.0 - Note: sidebar may reset. This can be fixed with a mouse. Calls broken
* 5.32.0
* 5.34.0
* 5.34.0
* 5.36.0
* 5.38.0

## sourcehut builds notes:

to publish a new release:

- find latest stable tag from [upstream repo](https://github.com/signalapp/Signal-Desktop/releases)
- edit `Dockerfile` and set git clone to pull the correct branch (format is "5.45.x")
- run `update-node 5.45.x` to set Dockefile to use upstream's specified nodejs version
    - for '5.45.1' or other versions, you use the same '5.45.x' argument.
- update `org.signal.Signal.metainfo.xml` with the new version
- edit `.builds.yml` and set `environment.VERSION` to new version
- push changes and sourcehut builds should trigger a new build

