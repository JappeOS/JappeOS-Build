#!/usr/bin/env bash
set -e

echo "[customize_airootfs.sh] Setting default target to graphical.target"
ln -sf /usr/lib/systemd/system/graphical.target /etc/systemd/system/default.target

echo "[customize_airootfs.sh] Enabling core service"
systemctl enable jappeos-core.service
# Line below fixes an issue with the reflector service blocking boot
systemctl disable reflector.service
systemctl enable reflector.timer

echo "[customize_airootfs.sh] Setting Plymouth theme"
plymouth-set-default-theme bgrt
mkinitcpio -P
systemctl enable plymouth-start.service
systemctl enable plymouth-quit.service
systemctl enable plymouth-quit-wait.service

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

echo "[customize_airootfs.sh] Configuring late services"
LATE_SERVICES_FILE="/root/late_services.list"

# Ensure file exists
if [ ! -f "$LATE_SERVICES_FILE" ]; then
    echo "[customize_airootfs.sh] Late services file not found: $LATE_SERVICES_FILE"
    exit 0
fi

while IFS= read -r service; do
    # Trim whitespace
    service="$(echo "$service" | tr -d '[:space:]')"

    # Skip empty or comment lines
    [ -z "$service" ] && continue
    [[ "$service" == \#* ]] && continue

    # Create override directory and file
    override_dir="/etc/systemd/system/${service}.d"
    mkdir -p "$override_dir"

    cat > "${override_dir}/delay.conf" <<EOF
[Unit]
After=late-system.target

[Install]
WantedBy=late-system.target
EOF

done < "$LATE_SERVICES_FILE"
