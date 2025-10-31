#!/usr/bin/env bash
set -e

echo "[customize_airootfs.sh] Setting default target to graphical.target"
ln -sf /usr/lib/systemd/system/graphical.target /etc/systemd/system/default.target

echo "[customize_airootfs.sh] Enabling core service"
systemctl enable jappeos-core.service

echo "[customize_airootfs.sh] Setting permissions"
chmod 755 /jappeos/jappeos_core
chmod -R 755 /jappeos

echo "[customize_airootfs.sh] Writing /etc/issue and /etc/issue.net"
echo "JappeOS \n \l" > /etc/issue
echo "JappeOS" > /etc/issue.net

echo "[customize_airootfs.sh] Writing /etc/os-release"
cat > /etc/os-release <<'EOF'
NAME="JappeOS"
PRETTY_NAME="JappeOS"
ID=jappeos
LOGO=jappeos-logo
BUILD_ID=$(date +%Y%m%d)
HOME_URL="https://jappeos.github.io/"
VENDOR_NAME="Jappe Studios"
DEFAULT_HOSTNAME=jappeos-????-????-????
EOF