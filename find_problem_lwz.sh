#!/bin/bash
# Find which lwz instructions in generated code might be problematic

cd "$(dirname "$0")/src"

echo "=== Analyzing lwz vs ld usage in generated assembly ==="
echo ""

# The opcodes we care about:
# lwz = 0x80______ (opcode 32, bits 0-5)
# ld  = 0xE8______ (opcode 58, bits 0-5) 
# Note: ld has bit pattern 111010xx in top byte

echo "Checking first 100 lines of generated assembly for load patterns..."
echo ""

# Extract first 100 .long directives and check for pointer-like operations
head -500 lj_vm.S | grep "\.long" | head -20 | while read -r line; do
    echo "$line"
done

echo ""
echo "Key insight: The .long directives are RAW OPCODES, not source."
echo "The macros (lp/stp) were already expanded by buildvm/DynASM."
echo ""
echo "Since we found 106 ld and 499 lwz instructions:"
echo "- The 106 ld instructions are from our lp macro fixes (pointer loads)"
echo "- The 499 lwz instructions are legitimate 32-bit loads (integers, not pointers)"
echo ""
echo "The crash might be from a SPECIFIC pointer operation we missed."
echo "Let's check the vm_pcall entry point specifically..."
echo ""

# Try to find vm_pcall in the assembly
grep -n "lj_vm_pcall\|vm_pcall:" lj_vm.S | head -3

# Made with Bob
