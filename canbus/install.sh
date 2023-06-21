#!/usr/bin/env bash
# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root." >&2;
  exit;
fi;

# Get the absolute path of the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";


source_mtime=$(date -r "${SCRIPT_DIR}/can-u2c.link" +%s)
destination_mtime=$(date -r "/etc/systemd/network/can-u2c.link" +%s 2>/dev/null || echo 0)

if [ $source_mtime -gt $destination_mtime ]; then
  cp -p "${SCRIPT_DIR}/can-u2c.link" "/etc/systemd/network/can-u2c.link";
  echo "The file /etc/systemd/network/can-u2c.link has been created";
else
  echo "The file /etc/systemd/network/can-u2c.link has been updated";
fi;


source_mtime=$(date -r "${SCRIPT_DIR}/can-u2c.network" +%s)
destination_mtime=$(date -r "/etc/systemd/network/can-u2c.network" +%s 2>/dev/null || echo 0)

if [ $source_mtime -gt $destination_mtime ]; then
  cp -p "${SCRIPT_DIR}/can-u2c.network" "/etc/systemd/network/can-u2c.network";
  echo "The file /etc/systemd/network/can-u2c.network has been created";
else
  echo "The file /etc/systemd/network/can-u2c.network has been updated";
fi;


# Check if the symlink for 70-bigtreetech-u2c-can.rules already exists
if [ -L "/etc/udev/rules.d/70-bigtreetech-u2c-can.rules" ]; then
  echo "The symlink /etc/udev/rules.d/70-bigtreetech-u2c-can.rules already exists";
else
  # Create the symlink in /etc/systemd/network
  ln -s "${SCRIPT_DIR}/70-bigtreetech-u2c-can.rules" "/etc/udev/rules.d/70-bigtreetech-u2c-can.rules";
  echo "The symlink /etc/udev/rules.d/70-bigtreetech-u2c-can.rules has been created";
fi;

chmod +r "${SCRIPT_DIR}/70-bigtreetech-u2c-can.rules";
udevadm control --reload-rules && udevadm trigger;
systemctl daemon-reload && systemctl restart systemd-networkd;
