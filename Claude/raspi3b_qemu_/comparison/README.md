ls -la
total 984
drwxrwxr-x 2 freddie freddie   4096 Mar 13 16:25 .
drwxrwxr-x 5 freddie freddie   4096 Mar 13 20:10 ..
-rwxrwxr-x 1 freddie freddie 526376 Mar 13 20:11 bad.img
-rwxrwxr-x 1 freddie freddie 526320 Mar 13 20:10 good.img

cmp bad.img good.img 
bad.img good.img differ: byte 33, line 1


TODO:
arm-none-eabi-objdump -d build/kernel.img.good > good.dump
arm-none-eabi-objdump -d build/kernel.img.bad > bad.dump
diff good.dump bad.dump

arm-none-eabi-readelf -l build/kernel.img.good > good.segments
arm-none-eabi-readelf -l build/kernel.img.bad > bad.segments
diff good.segments bad.segments

nm build/kernel.img.good > good.symbols
nm build/kernel.img.bad > bad.symbols
diff good.symbols bad.symbols


    Add the debug hook to inspect register/memory state before divergence
    Apply the force-path patches to eliminate conditional branches
    Use QEMU's monitor with:



Claude prompt:
I have an ARM baremetal decryption program for which I have 2 tests, 1 & 2. The first decrypts correctly but the second does not. I have compared objdumps of the img files, the programs should both deterministically use the same branches and logic but seemingly they do not. Can you help me write a bash script that applies necessary changes to the bad.img so that it mimics the correct decryption technique?
I am not even certain if the KDF is correct, could you help with that too? I can provide any file you like I will start with goodBad.dumpDiff which I generated from: 
2014  arm-none-eabi-objdump -d good.img > good.dump
 2015  arm-none-eabi-objdump -d bad.img > bad.dump
 2016  diff good.dump bad.dump 
 2017  diff good.dump bad.dump  > goodBad.diff
 2018  diff good.dump bad.dump  > goodBad.dumpDiff

 Here is the main function detailing the 2 test types, only 3 toggled comments are needed to switch between the types and here it is in the bad test configuration:

void main()
{
    init_printf(0, putc_uart);
    // print_memory_map();

    // Properly allocate control structure with debug output
    ctrl_t ctrl = malloc(sizeof(struct server_control_s));
    if (!ctrl) {
        printf("Failed to allocate control structure\n");
        goto cleanup;
    }
    
    // Initialize with debug output
    memset(ctrl, 0, sizeof(struct server_control_s));

    // const char *test_passphrase = "password"; // Test 1. Good PW
    const char *test_passphrase = "2af14ef19220d275b0f87907f4ab5075dc9b75b574ef8c2e06e32e8311776945"; // Test 2. Good PW
    size_t pass_len = strlen(test_passphrase);
    
    ctrl->passphrase = malloc(pass_len + 1);
    if (!ctrl->passphrase) {
        printf("Failed to allocate passphrase\n");
        goto cleanup;
    }
    
    my_strcpy(ctrl->passphrase, test_passphrase);
    
    // // Set up and verify session key
    // const char *key = "693B7847FA44CDC6E1C403F5E44E95C1"; // Test 1. Good Derived Key
    // // const char *key = "427c028e28eeb15464c376d7dcca6ca2"; // Test 2. Good/Bad Derived Key???
    // size_t key_len = strlen(key);
    // ctrl->session_key = malloc(key_len + 1);
    // my_strcpy(ctrl->session_key, key);

    ctrl->session_key = NULL; // Force KDF

    // Add some guard values
    uint32_t guard1 = 0xDEADBEEF;
    uint32_t guard2 = 0xBABECAFE;
    printf("Guard values before decrypt: 0x%08X 0x%08X\n", guard1, guard2);
    
    // Decrypt the data
    // int rc = decrypt_memory(ctrl, encrypted_1k_gpg, encrypted_1k_gpg_len); // Test 1. Good Decrypt
    int rc = decrypt_memory(ctrl, __7379ab5047b143c0b6cfe5d8d79ad240b4b4f8cced55aa26f86d1d3d370c0d4c_gpg, __7379ab5047b143c0b6cfe5d8d79ad240b4b4f8cced55aa26f86d1d3d370c0d4c_gpg_len); // Test 2. BAD DECRYPT !!!!
    if (rc) {
        printf("Decryption failed with code: %d\n", rc);
    }
    // Check guard values
    printf("Guard values after decrypt: 0x%08X 0x%08X\n", guard1, guard2);
    
cleanup:
    while (1) {
        __asm__("wfi");
    }
}