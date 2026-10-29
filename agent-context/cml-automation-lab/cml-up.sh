#!/bin/bash
# Let the CML VM use promiscuous mode on the bridged network, then start it.
# The access lasts until the machine reboots.
set -euo pipefail

VMNET=/dev/vmnet0
VMX="${CML_VMX:-$HOME/vmware/cisco-modeling-lab/cisco-modeling-lab.vmx}"

if vmrun -T ws list | grep -qF "$VMX"; then
  echo "CML VM is already running. Shut it down first: it only picks up $VMNET access at power-on." >&2
  exit 1
fi

sudo chgrp "$(id -gn)" "$VMNET"
sudo chmod g+rw "$VMNET"
vmrun -T ws start "$VMX"
