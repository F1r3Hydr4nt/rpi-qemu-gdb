#!/bin/bash
# Script to find mainproc.c in your project

echo "Searching for mainproc.c in your project directory..."
find . -name "mainproc.c" -type f

echo -e "\nSearching for references to proc_encryption_packets function..."
find . -type f -name "*.c" -o -name "*.h" | xargs grep -l "proc_encryption_packets"

echo -e "\nChecking if packet.h exists and mentions proc_encryption_packets..."
find . -name "packet.h" -type f -exec grep -l "proc_encryption_packets" {} \;


