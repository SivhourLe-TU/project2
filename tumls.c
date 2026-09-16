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

// Function to list files opened in the current directory
static void print_entries(DIR *dir, const char *dirpath){
    struct dirent *entry;
    while ((entry = readdir(dir)) != NULL){
        char fullpath[4096];
        snprintf(fullpath, sizeof(fullpath), "%s/%s", dirpath, entry->d_name);
        struct stat st;
        if (stat(fullpath, &st) == -1) {
            continue; // Skip if stat fails
        }
    
        char perm[10];
        mode_to_string(st.st_mode, perm);
        printf("%s %s %ld %s\n", S_ISDIR(st.st_mode) ? "[DIR]" : "[FILE]", perm, 
                                (long)st.st_size, entry->d_name);
    }
}