#!/bin/bash
# Check what's actually in the generated assembly

cd "$(dirname "$0")/src"

if [ ! -f "lj_vm.S" ]; then
    echo "lj_vm.S not found. Run 'make' first."
    exit 1
fi

echo "=== Checking generated lj_vm.S assembly ==="
echo ""

echo "1. File size and line count:"
ls -lh lj_vm.S
wc -l lj_vm.S
echo ""

echo "2. First 50 lines of lj_vm.S:"
head -50 lj_vm.S
echo ""

echo "3. Searching for pointer load instructions:"
echo "   Looking for 'ld' (64-bit) vs 'lwz' (32-bit)..."
echo ""
echo "   First 5 occurrences of 'ld ' instruction:"
grep -n "^\s*ld " lj_vm.S | head -5
echo ""
echo "   First 5 occurrences of 'lwz' instruction:"
grep -n "^\s*lwz" lj_vm.S | head -5
echo ""

echo "4. Checking specific DISPATCH-related instructions:"
grep -n "DISPATCH" lj_vm.S | head -10

# Made with Bob
