FROM archlinux:latest

# Install archiso and build tools
RUN pacman -Sy --noconfirm archlinux-keyring && \
    pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman -Syu --noconfirm archiso git base-devel && \
    pacman -Scc --noconfirm

WORKDIR /build