#!/bin/bash
# Script to check what TARGET_TESTARCH contains during build

cd "$(dirname "$0")/src"

echo "=== Checking TARGET_TESTARCH ==="
echo ""

# Simulate what the Makefile does
TARGET_CC="${CC:-gcc}"
TARGET_TCFLAGS="-I."

echo "Running: $TARGET_CC $TARGET_TCFLAGS -E lj_arch.h -dM"
echo ""

TARGET_TESTARCH=$($TARGET_CC $TARGET_TCFLAGS -E lj_arch.h -dM)

echo "=== Full TARGET_TESTARCH output ==="
echo "$TARGET_TESTARCH" | grep "LJ_"
echo ""

echo "=== Checking specific flags ==="
echo -n "LJ_ARCH_BITS 64: "
if echo "$TARGET_TESTARCH" | grep -q "LJ_ARCH_BITS 64"; then
    echo "FOUND ✓"
else
    echo "NOT FOUND ✗"
fi

echo -n "LJ_TARGET_PPC: "
if echo "$TARGET_TESTARCH" | grep -q "LJ_TARGET_PPC"; then
    echo "FOUND ✓"
else
    echo "NOT FOUND ✗"
fi

echo -n "LJ_ARCH_ELFV2 1: "
if echo "$TARGET_TESTARCH" | grep -q "LJ_ARCH_ELFV2 1"; then
    echo "FOUND ✓"
else
    echo "NOT FOUND ✗"
fi

echo -n "LJ_TARGET_GC64 1: "
if echo "$TARGET_TESTARCH" | grep -q "LJ_TARGET_GC64 1"; then
    echo "FOUND ✓"
else
    echo "NOT FOUND ✗"
fi

echo ""
echo "=== What DASM_AFLAGS should be ==="
DASM_AFLAGS=""

if echo "$TARGET_TESTARCH" | grep -q "LJ_LE 1"; then
    DASM_AFLAGS="$DASM_AFLAGS -D ENDIAN_LE"
else
    DASM_AFLAGS="$DASM_AFLAGS -D ENDIAN_BE"
fi

if echo "$TARGET_TESTARCH" | grep -q "LJ_ARCH_BITS 64"; then
    DASM_AFLAGS="$DASM_AFLAGS -D P64"
fi

if echo "$TARGET_TESTARCH" | grep -q "LJ_TARGET_PPC"; then
    if echo "$TARGET_TESTARCH" | grep -q "LJ_ARCH_BITS 64"; then
        DASM_AFLAGS="$DASM_AFLAGS -D GPR64 -D P64"
        if echo "$TARGET_TESTARCH" | grep -q "LJ_ARCH_ELFV2 1"; then
            DASM_AFLAGS="$DASM_AFLAGS -D ELFV2"
        fi
    fi
fi

echo "DASM_AFLAGS should be: $DASM_AFLAGS"
echo ""

echo "=== Checking if buildvm_arch.h has GPR64 ==="
if [ -f "host/buildvm_arch.h" ]; then
    echo -n "GPR64 in buildvm_arch.h: "
    if grep -q "GPR64" host/buildvm_arch.h; then
        echo "FOUND ✓"
    else
        echo "NOT FOUND ✗"
    fi
else
    echo "buildvm_arch.h does not exist yet"
fi

# Made with Bob
