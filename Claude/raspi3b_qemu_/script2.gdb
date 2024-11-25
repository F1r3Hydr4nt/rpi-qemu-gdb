# script2.gdb - run after hitting main
watch -l *(char(*)[8])passphrase
display/s passphrase
display/x passphrase
awatch *(char*)passphrase@8
continue

#Start with: gdb-multiarch $(TARGET) -x script1.gdb
#When it hits main, type: source script2.gdb