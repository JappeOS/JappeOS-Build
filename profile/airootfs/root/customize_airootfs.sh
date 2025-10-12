#!/usr/bin/env bash
set -e

echo "[customize_airootfs.sh] Setting default target to graphical.target"
ln -sf /usr/lib/systemd/system/graphical.target /etc/systemd/system/default.target

echo "[customize_airootfs.sh] Enabling core service"
systemctl enable jappeos-core.service