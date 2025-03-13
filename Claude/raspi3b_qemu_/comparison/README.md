ls -la
total 984
drwxrwxr-x 2 freddie freddie   4096 Mar 13 16:25 .
drwxrwxr-x 5 freddie freddie   4096 Mar 13 20:10 ..
-rwxrwxr-x 1 freddie freddie 526376 Mar 13 20:11 bad.img
-rwxrwxr-x 1 freddie freddie 526320 Mar 13 20:10 good.img

cmp bad.img good.img 
bad.img good.img differ: byte 33, line 1


TODO:
objdump -d build/kernel.img.good > good.dump
objdump -d build/kernel.img.bad > bad.dump
diff good.dump bad.dump

readelf -l build/kernel.img.good > good.segments
readelf -l build/kernel.img.bad > bad.segments
diff good.segments bad.segments

nm build/kernel.img.good > good.symbols
nm build/kernel.img.bad > bad.symbols
diff good.symbols bad.symbols


    Add the debug hook to inspect register/memory state before divergence
    Apply the force-path patches to eliminate conditional branches
    Use QEMU's monitor with:
