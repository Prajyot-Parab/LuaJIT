#!/bin/bash
# Decode PPC opcodes to see what instructions are actually being used

cd "$(dirname "$0")/src"

echo "=== Decoding PPC opcodes from lj_vm.S ==="
echo ""

# Extract some .long values and decode them
echo "Decoding first few instructions from lj_BC_ISLT:"
echo ""

# Function to decode a PPC opcode (simplified - just check for ld vs lwz)
decode_opcode() {
    local hex=$1
    local decimal=$((16#$hex))
    local opcode=$((decimal >> 26))
    
    # PPC opcodes:
    # lwz = 32 (0x20)
    # ld = 58 (0x3A) 
    # std = 62 (0x3E)
    # lwzu = 33 (0x21)
    
    case $opcode in
        32) echo "  0x$hex -> lwz (32-bit load)" ;;
        58) echo "  0x$hex -> ld (64-bit load)" ;;
        62) echo "  0x$hex -> std (64-bit store)" ;;
        33) echo "  0x$hex -> lwzu (32-bit load with update)" ;;
        *) echo "  0x$hex -> opcode $opcode (other instruction)" ;;
    esac
}

# Extract and decode first 20 opcodes
grep "\.long" lj_vm.S | head -5 | while read -r line; do
    # Extract hex values from the line
    for hex in $(echo "$line" | grep -oE '0x[0-9a-f]{8}'); do
        hex_clean=$(echo "$hex" | sed 's/0x//' | sed 's/,//')
        decode_opcode "$hex_clean"
    done
done

echo ""
echo "Summary: Checking if any 64-bit load/store instructions are present..."
echo ""

# Count ld instructions (opcode 58 = 0x3A)
ld_count=$(grep "\.long" lj_vm.S | grep -oE '0x[0-9a-f]{8}' | \
    awk '{val=strtonum($1); opcode=rshift(val,26); if(opcode==58) print}' | wc -l)

# Count lwz instructions (opcode 32 = 0x20)  
lwz_count=$(grep "\.long" lj_vm.S | grep -oE '0x[0-9a-f]{8}' | \
    awk '{val=strtonum($1); opcode=rshift(val,26); if(opcode==32) print}' | wc -l)

echo "64-bit ld instructions found: $ld_count"
echo "32-bit lwz instructions found: $lwz_count"
echo ""

if [ "$ld_count" -eq 0 ] && [ "$lwz_count" -gt 0 ]; then
    echo "❌ PROBLEM: Only 32-bit lwz found, no 64-bit ld instructions!"
    echo "   This means P64 flag is NOT being applied during DynASM preprocessing."
elif [ "$ld_count" -gt 0 ]; then
    echo "✓ Good: Found 64-bit ld instructions"
fi

# Made with Bob
