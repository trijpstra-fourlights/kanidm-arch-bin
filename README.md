# kanidm-archlinux

Arch Linux package builds for kanidm.

## Build

```sh
./build-kanidm.sh
```

Or with Docker:
```sh
docker build -t kanidm-builder .
docker create --name kanidm-builder kanidm-builder
docker cp kanidm-builder:/home/builder/build/ ./output/
docker rm kanidm-builder
```

## Install

```sh
sudo pacman -U output/*.pkg.tar.zst
```

## GitHub Releases

Push a tag matching `v*` to trigger a build and release.
