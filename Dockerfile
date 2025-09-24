FROM archlinux:latest

# Install archiso and build tools
RUN pacman -Syu --noconfirm archiso git base-devel && pacman -Scc --noconfirm

WORKDIR /build