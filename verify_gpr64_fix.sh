#!/bin/bash
# Verify that DynASM GPR64 conditionals are now working correctly

echo "=== Verifying DynASM GPR64 Conditional Fix ==="
echo ""

# Check if buildvm_arch.h contains the 64-bit SAVE_GPR_ offset (112)
echo "1. Checking for 64-bit SAVE_GPR_ offset in buildvm_arch.h:"
if grep -q "SAVE_GPR_.*112" src/host/buildvm_arch.h 2>/dev/null; then
    echo "   ✓ Found SAVE_GPR_ = 112 (64-bit offset)"
    grep "SAVE_GPR_" src/host/buildvm_arch.h | head -5
else
    echo "   ✗ SAVE_GPR_ = 112 not found"
    echo "   Current SAVE_GPR_ values:"
    grep "SAVE_GPR_" src/host/buildvm_arch.h | head -5
fi

echo ""
echo "2. Checking for 32-bit SAVE_GPR_ offset (56) - should NOT be present:"
if grep -q "SAVE_GPR_.*56[^0-9]" src/host/buildvm_arch.h 2>/dev/null; then
    echo "   ✗ WARNING: Found SAVE_GPR_ = 56 (32-bit offset) - conditionals may not be working!"
    grep "SAVE_GPR_.*56" src/host/buildvm_arch.h | head -3
else
    echo "   ✓ No 32-bit SAVE_GPR_ = 56 found"
fi

echo ""
echo "3. Checking for FRAME32 offset (232) - should NOT be present on pure 64-bit:"
if grep -q "SAVE_GPR_.*232" src/host/buildvm_arch.h 2>/dev/null; then
    echo "   ✗ WARNING: Found SAVE_GPR_ = 232 (FRAME32 offset)"
    grep "SAVE_GPR_.*232" src/host/buildvm_arch.h | head -3
else
    echo "   ✓ No FRAME32 SAVE_GPR_ = 232 found"
fi

echo ""
echo "4. Checking GPR64 flag detection in buildvm_arch.h:"
if grep -q "#if.*GPR64" src/host/buildvm_arch.h 2>/dev/null; then
    echo "   ✓ GPR64 conditionals present"
    grep -n "#if.*GPR64\|#ifdef.*GPR64" src/host/buildvm_arch.h | head -5
else
    echo "   ✗ No GPR64 conditionals found"
fi

echo ""
echo "5. Summary of SAVE_GPR_ definitions:"
grep -E "define.*SAVE_GPR_|SAVE_GPR_.*=" src/host/buildvm_arch.h 2>/dev/null | head -10

echo ""
echo "=== Verification Complete ==="

# Made with Bob
