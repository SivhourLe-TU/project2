/*
tumls.c

program that mimicks the Linux "ls" program



*/ 
#include <stdio.h>
#include <dirent.h>
#include <sys/stat.h>

// Function to convert st_mode to a rwxrwxrwx\0 string
void mode_to_string(mode_t mode, char *out) {
    const int bits[9] = {S_IRUSR, S_IWUSR, S_IXUSR,
                        S_IRGRP, S_IWGRP, S_IXGRP,
                        S_IROTH, S_IWOTH, S_IXOTH};
    const char chars[9] = {'r', 'w', 'x', 'r', 'w', 'x', 'r', 'w', 'x'};

    for (int i = 0; i < 9; i++) {
        out[i] = (mode & bits[i]) ? chars[i] : '-';
    }
    out[9] = '\0'; // Null-terminate the string
}    