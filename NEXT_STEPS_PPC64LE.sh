#!/bin/bash
# Commands to run on ppc64le hardware to apply the DynASM fix and test

echo "=========================================="
echo "LuaJIT ppc64le - Next Steps"
echo "=========================================="
echo ""

# Step 1: Verify we're on ppc64le
echo "Step 1: Verify architecture"
echo "----------------------------"
echo "$ uname -m"
uname -m
echo ""
if [ "$(uname -m)" != "ppc64le" ]; then
    echo "WARNING: Not on ppc64le architecture!"
    echo "These commands should be run on ppc64le hardware."
    exit 1
fi

# Step 2: Backup current dynasm.lua
echo "Step 2: Backup current dynasm.lua"
echo "----------------------------------"
echo "$ cp dynasm/dynasm.lua dynasm/dynasm.lua.backup"
cp dynasm/dynasm.lua dynasm/dynasm.lua.backup
echo "Backup created: dynasm/dynasm.lua.backup"
echo ""

# Step 3: Show the diff that needs to be applied
echo "Step 3: The DynASM fix has already been applied to dynasm/dynasm.lua"
echo "---------------------------------------------------------------------"
echo "The cond_eval() function (lines 260-295) now includes defines in the"
echo "evaluation environment, allowing .if GPR64 conditionals to work correctly."
echo ""

# Step 4: Clean and rebuild
echo "Step 4: Clean and rebuild LuaJIT"
echo "---------------------------------"
echo "$ make clean"
make clean
echo ""
echo "$ make"
make
echo ""

if [ $? -ne 0 ]; then
    echo "ERROR: Build failed!"
    echo "Please check the error messages above."
    exit 1
fi

echo "Build successful!"
echo ""

# Step 5: Verify the fix worked
echo "Step 5: Verify the DynASM fix worked"
echo "-------------------------------------"
echo "$ ./verify_gpr64_fix.sh"
./verify_gpr64_fix.sh
echo ""

# Step 6: Check generated assembly
echo "Step 6: Check generated assembly for correct offsets"
echo "-----------------------------------------------------"
echo "Looking for 'ld r27,112(r1)' (correct) vs 'ld r27,56(r1)' (wrong):"
echo ""
echo "$ grep -E 'ld r27.*(56|112)\(r1\)' src/lj_vm.S | head -5"
grep -E 'ld r27.*(56|112)\(r1\)' src/lj_vm.S | head -5
echo ""

# Step 7: Test basic execution
echo "Step 7: Test basic execution"
echo "----------------------------"
echo "$ ./src/luajit -e \"print('Hello from ppc64le with fixed DynASM!')\""
./src/luajit -e "print('Hello from ppc64le with fixed DynASM!')"
echo ""

if [ $? -eq 0 ]; then
    echo "SUCCESS! LuaJIT is running on ppc64le!"
    echo ""
    echo "Step 8: Run more comprehensive tests"
    echo "-------------------------------------"
    echo "$ ./src/luajit -e \"print('Testing math:', 2+2)\""
    ./src/luajit -e "print('Testing math:', 2+2)"
    echo ""
    echo "$ ./src/luajit -e \"for i=1,5 do print('Loop', i) end\""
    ./src/luajit -e "for i=1,5 do print('Loop', i) end"
    echo ""
    echo "$ ./src/luajit -e \"local t = {a=1, b=2}; print('Table:', t.a, t.b)\""
    ./src/luajit -e "local t = {a=1, b=2}; print('Table:', t.a, t.b)"
    echo ""
else
    echo "FAILED: LuaJIT crashed or returned error"
    echo ""
    echo "Debugging steps:"
    echo "1. Check if correct stack offset (112) is being used:"
    echo "   $ grep 'SAVE_GPR_' src/host/buildvm_arch.h | grep -v '//' | head -5"
    echo ""
    echo "2. Run with GDB to see where it crashes:"
    echo "   $ gdb --args ./src/luajit -e \"print('test')\""
    echo "   (gdb) run"
    echo "   (gdb) bt"
    echo ""
    echo "3. Check the assembly around the crash:"
    echo "   $ objdump -d src/luajit | grep -A20 'lj_BC_FUNCC'"
    echo ""
fi

echo ""
echo "=========================================="
echo "Next Steps Summary"
echo "=========================================="
echo ""
echo "If basic execution works:"
echo "  1. Run test suite: cd test && ./test.lua"
echo "  2. Test more complex scripts"
echo "  3. Document any remaining issues"
echo ""
echo "If execution still fails:"
echo "  1. Check verify_gpr64_fix.sh output"
echo "  2. Verify SAVE_GPR_ = 112 is being used"
echo "  3. Use GDB to debug the crash"
echo "  4. Check if there are other 32-bit operations we missed"
echo ""
echo "Documentation:"
echo "  - DYNASM_FIX_README.md - Details about the DynASM fix"
echo "  - PPC64LE_PORT_SUMMARY.md - Complete port summary"
echo ""

# Made with Bob
