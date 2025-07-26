#include <unistd.h>
int main() {
    const char msg[] = "Hello from initramfs!\n";
    write(1, msg, sizeof(msg)-1);
    for (;;) pause();
}