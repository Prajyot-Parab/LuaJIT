#!/bin/bash
# Diagnostic script to check if P64 flags are being set correctly

echo "=== Checking build configuration on ppc64le ==="
echo ""

cd "$(dirname "$0")/src"

echo "1. Checking preprocessor defines from lj_arch.h:"
gcc -E lj_arch.h -dM 2>/dev/null | grep -E "LJ_ARCH_BITS|LJ_ARCH_ELFV2|LJ_TARGET_PPC|_LP64"
echo ""

echo "2. Checking TARGET_TESTARCH variable:"
TARGET_TESTARCH=$(gcc -E lj_arch.h -dM 2>/dev/null)
echo "LJ_ARCH_BITS: $(echo "$TARGET_TESTARCH" | grep 'LJ_ARCH_BITS')"
echo "LJ_TARGET_PPC: $(echo "$TARGET_TESTARCH" | grep 'LJ_TARGET_PPC')"
echo "LJ_ARCH_ELFV2: $(echo "$TARGET_TESTARCH" | grep 'LJ_ARCH_ELFV2')"
echo ""

echo "3. Simulating Makefile logic:"
if echo "$TARGET_TESTARCH" | grep -q "LJ_TARGET_PPC"; then
    echo "✓ LJ_TARGET_PPC found - TARGET_LJARCH would be set to 'ppc'"
    
    if echo "$TARGET_TESTARCH" | grep -q "LJ_ARCH_BITS 64"; then
        echo "✓ LJ_ARCH_BITS 64 found - Should add: -D GPR64 -D P64"
        
        if echo "$TARGET_TESTARCH" | grep -q "LJ_ARCH_ELFV2 1"; then
            echo "✓ LJ_ARCH_ELFV2 1 found - Should add: -D ELFV2"
        else
            echo "✗ LJ_ARCH_ELFV2 1 NOT found"
        fi
    else
        echo "✗ LJ_ARCH_BITS 64 NOT found - P64 flag will NOT be set!"
    fi
else
    echo "✗ LJ_TARGET_PPC NOT found"
fi
echo ""

echo "4. Checking generated lj_vm.S (if it exists):"
if [ -f "lj_vm.S" ]; then
    echo "First occurrence of DISPATCH load:"
    grep -n "l[dw].*DISPATCH" lj_vm.S | head -1
    echo ""
    echo "Macro definitions (if present in first 200 lines):"
    head -200 lj_vm.S | grep -E "\.macro (lp|stp)"
else
    echo "lj_vm.S not found - run 'make' first"
fi

# Made with Bob
