Looking at the diff output from your two kernel builds, I can see a clear pattern of differences. Most of the changes are related to memory addresses or offsets within the compiled code:

The main pattern is that most values in kernel1.img are 0x00000048 and the corresponding values in kernel2.img are 0x00000044 (a 4-byte difference).
There are a few other differences:

At address 0xd3c4: 0x00000050 vs 0x0000004c
At address 0xd3d8: 0x0000004c vs 0x00000048
At address 0xd3e0: 0x00000044 vs 0x00000040
At address 0x12858: 0x00000058 vs 0x00000054
At address 0x13540: 0x00000054 vs 0x00000050


And a more significant difference at the end:

At addresses 0x1354c and 0x13550, the values are completely different between the two builds.



These differences are consistent with what you'd expect from small code changes affecting memory layout and offsets. The 4-byte differences suggest that something in the second build is slightly smaller than in the first build, causing all subsequent addresses to shift.
Since your codebase appears to be working with encrypted data and GPG, these differences are probably related to either:

The different key values that are used for decryption
Different encrypted data being processed
Different code paths being taken for encryption/decryption

The comparison indicates that your build system is working properly, creating two distinct binaries with the differences you expect. You can now test both versions to see how they behave differently in your target environment.
