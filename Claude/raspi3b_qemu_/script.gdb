# script1.gdb - initial setup
target remote localhost:1234
break *_start
break main
# break my_strncpy
# break my_strlen
break decryptGPGData
# break encryptToGPGFormat
set history save on
set history filename ~/.gdb_history
set history size 10000
continue