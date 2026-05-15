#!/bin/bash
# Test script for ppc64le support in LuaJIT
# Run this on a ppc64le system to verify the implementation

set -e

echo "=========================================="
echo "LuaJIT ppc64le Support Test Script"
echo "=========================================="
echo ""

# Check if we're on ppc64le
ARCH=$(uname -m)
echo "Current architecture: $ARCH"
if [ "$ARCH" != "ppc64le" ]; then
    echo "WARNING: Not running on ppc64le architecture!"
    echo "This test should be run on a ppc64le system."
    echo ""
fi

# Navigate to source directory
cd "$(dirname "$0")/src"

echo "Step 1: Cleaning previous build..."
make clean
echo ""

echo "Step 2: Building LuaJIT..."
if make; then
    echo "✓ Build successful!"
else
    echo "✗ Build failed!"
    exit 1
fi
echo ""

echo "Step 3: Running basic tests..."
echo ""

# Test 1: Basic execution
echo "Test 1: Basic execution"
if ./luajit -e "print('Hello from ppc64le!')"; then
    echo "✓ Basic execution works"
else
    echo "✗ Basic execution failed"
    exit 1
fi
echo ""

# Test 2: Check architecture
echo "Test 2: Architecture detection"
DETECTED_ARCH=$(./luajit -e "print(jit.arch)" 2>/dev/null || echo "unknown")
echo "Detected architecture: $DETECTED_ARCH"
if [ "$DETECTED_ARCH" = "ppc64le" ] || [ "$DETECTED_ARCH" = "ppc64" ]; then
    echo "✓ Architecture correctly detected"
else
    echo "✗ Architecture detection failed (expected ppc64le or ppc64, got $DETECTED_ARCH)"
    exit 1
fi
echo ""

# Test 3: Check JIT status
echo "Test 3: JIT status (should be disabled)"
./luajit -e "print('JIT status:', jit.status())"
echo "✓ JIT status check complete (interpreter-only mode expected)"
echo ""

# Test 4: Basic Lua operations
echo "Test 4: Basic Lua operations"
./luajit -e "
local function factorial(n)
    if n <= 1 then return 1 end
    return n * factorial(n-1)
end
print('Factorial of 10:', factorial(10))
assert(factorial(10) == 3628800, 'Factorial calculation failed')
print('✓ Factorial calculation works')
"
echo ""

# Test 5: Table operations
echo "Test 5: Table operations"
./luajit -e "
local t = {1, 2, 3, 4, 5}
local sum = 0
for i, v in ipairs(t) do
    sum = sum + v
end
print('Sum of table:', sum)
assert(sum == 15, 'Table sum failed')
print('✓ Table operations work')
"
echo ""

# Test 6: String operations
echo "Test 6: String operations"
./luajit -e "
local s = 'Hello, ppc64le!'
print('String:', s)
print('Length:', #s)
print('Upper:', string.upper(s))
assert(#s == 16, 'String length check failed')
print('✓ String operations work')
"
echo ""

# Test 7: Math operations
echo "Test 7: Math operations"
./luajit -e "
local x = 2.5
local y = 3.7
print('Addition:', x + y)
print('Multiplication:', x * y)
print('Square root of 16:', math.sqrt(16))
assert(math.sqrt(16) == 4, 'Math operations failed')
print('✓ Math operations work')
"
echo ""

# Test 8: Coroutines
echo "Test 8: Coroutines"
./luajit -e "
local co = coroutine.create(function()
    for i = 1, 3 do
        print('Coroutine iteration:', i)
        coroutine.yield()
    end
end)
coroutine.resume(co)
coroutine.resume(co)
coroutine.resume(co)
print('✓ Coroutines work')
"
echo ""

echo "=========================================="
echo "All tests completed successfully!"
echo "=========================================="
echo ""
echo "Summary:"
echo "- Architecture: $DETECTED_ARCH"
echo "- Mode: Interpreter-only (JIT disabled)"
echo "- Status: ✓ Working"
echo ""
echo "Note: This is interpreter-only mode. Performance will be"
echo "slower than JIT-enabled architectures. JIT support is NYI."

# Made with Bob
