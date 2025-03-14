#!/bin/bash
# runTests.sh - Run both test cases and generate comparisons

echo "=== Running Test 1 ==="
./runTest2.sh -t 1 -l

echo ""
echo "=== Running Test 2 and generating comparisons ==="
./runTest2.sh -t 2 -l -d

echo ""
echo "=== Testing completed ==="
echo "See results directory for analysis reports and comparisons."

