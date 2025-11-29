#!/usr/bin/env bash
set -euo pipefail

# Install systemd unit files for recetas backups (requires sudo/root)

UNIT_DIR=/etc/systemd/system
SRC_DIR="$(pwd)/scripts/systemd"

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo $0" >&2
  exit 1
fi

echo "Copying unit files to $UNIT_DIR"
cp "$SRC_DIR"/*.service "$UNIT_DIR"/
cp "$SRC_DIR"/*.timer "$UNIT_DIR"/

echo "Reloading systemd daemon"
systemctl daemon-reload

echo "Enabling and starting timers"
systemctl enable --now recetas-backup.timer
systemctl enable --now recetas-backup-rotate.timer

echo "Status:"
systemctl list-timers --all | egrep 'recetas-backup|recetas-backup-rotate' || true

echo "Installation completed. Backups will run daily at 02:00 (full) and 02:30 (rotate)."
