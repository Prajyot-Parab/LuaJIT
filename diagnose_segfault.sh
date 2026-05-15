#!/bin/bash
# Diagnose why LuaJIT is still segfaulting after DynASM fix

echo "=========================================="
echo "LuaJIT ppc64le Segfault Diagnosis"
echo "=========================================="
echo ""

echo "1. Check if SAVE_GPR_ definitions are correct in buildvm_arch.h"
echo "----------------------------------------------------------------"
echo "Looking for active (non-comment) SAVE_GPR_ definitions:"
grep -E "^[^/]*SAVE_GPR_" src/host/buildvm_arch.h | head -10
echo ""

echo "2. Check all SAVE_GPR_ references (including comments)"
echo "-------------------------------------------------------"
grep "SAVE_GPR_" src/host/buildvm_arch.h | head -15
echo ""

echo "3. Check for GPR64 conditionals in buildvm_arch.h"
echo "--------------------------------------------------"
grep -i "gpr64\|#if.*64\|#ifdef.*64" src/host/buildvm_arch.h | head -10
echo ""

echo "4. Check lj_vm.S for register save/restore operations"
echo "------------------------------------------------------"
echo "Looking for r27 operations (should use offset 112 for 64-bit):"
grep -E "ld r27|std r27|lwz r27|stw r27" src/lj_vm.S | head -10
echo ""

echo "5. Check lj_vm.S for stack frame setup"
echo "---------------------------------------"
echo "Looking for stack pointer operations:"
grep -E "stdu r1|stwu r1|addi r1" src/lj_vm.S | head -10
echo ""

echo "6. Check what DASM_AFLAGS were actually used during build"
echo "----------------------------------------------------------"
grep "DASM_AFLAGS" src/Makefile
echo ""

echo "7. Check the actual dynasm command that was run"
echo "------------------------------------------------"
echo "From build log, the dynasm command should include -D GPR64 -D P64 -D ELFV2"
echo "Let's verify by checking the Makefile target:"
grep -A5 "buildvm_arch.h:" src/Makefile
echo ""

echo "8. Test if defines are actually being passed"
echo "---------------------------------------------"
echo "Checking if GPR64 appears in buildvm_arch.h at all:"
grep -c "GPR64" src/host/buildvm_arch.h
echo ""

echo "9. Check for any error messages in build output"
echo "------------------------------------------------"
echo "Re-running just the dynasm step to see output:"
cd src && ../dynasm/dynasm.lua -D ENDIAN_LE -D P64 -D DUALNUM -D FPU -D HFABI -D VER=70 -D SQRT -D ROUND -D GPR64 -D P64 -D ELFV2 -o /tmp/test_buildvm_arch.h vm_ppc.dasc 2>&1 | head -20
echo ""

echo "10. Check if the cond_eval fix is actually in dynasm.lua"
echo "---------------------------------------------------------"
echo "Looking for 'map_def' in cond_eval function:"
grep -A10 "function cond_eval" dynasm/dynasm.lua | grep -E "map_def|env\[name\]"
echo ""

echo "=========================================="
echo "Diagnosis Complete"
echo "=========================================="

# Made with Bob
