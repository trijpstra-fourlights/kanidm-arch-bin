FROM archlinux:latest

ARG RUST_VERSION
ARG AUR_PACKAGE

RUN pacman-key --init && \
    pacman -Syu --noconfirm

RUN pacman -U --noconfirm \
    https://archive.archlinux.org/packages/r/rust/rust-1%3a1.94.0-1-x86_64.pkg.tar.zst \
    https://archive.archlinux.org/packages/l/llvm-libs/llvm-libs-21.1.8-1-x86_64.pkg.tar.zst \
    https://archive.archlinux.org/packages/c/clang/clang-21.1.8-1-x86_64.pkg.tar.zst \
    https://archive.archlinux.org/packages/l/lld/lld-21.1.8-1-x86_64.pkg.tar.zst

RUN pacman -S --noconfirm \
    base-devel \
    git \
    pkg-config

RUN useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder
WORKDIR /home/builder

RUN git clone https://aur.archlinux.org/${AUR_PACKAGE}.git build

WORKDIR /home/builder/build

RUN makepkg -s --noconfirm --skippgpcheck
