#!/bin/bash
# Test if DynASM flags are working

cd "$(dirname "$0")/src"

cat > test.dasc << 'EOF'
|.arch ppc
|.if GPR64
|  // GPR64 is defined
|  .define TEST_VALUE, 112
|.else
|  // GPR64 is NOT defined  
|  .define TEST_VALUE, 56
|.endif
EOF

echo "Testing DynASM with -D GPR64:"
../dynasm/dynasm.lua -D GPR64 test.dasc 2>&1 | head -20

echo ""
echo "Testing DynASM without -D GPR64:"
../dynasm/dynasm.lua test.dasc 2>&1 | head -20

rm -f test.dasc

# Made with Bob
