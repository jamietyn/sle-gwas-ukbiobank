#!/bin/bash
# Count variants in PLINK2 .snplist file
# Usage: ./count_variants.sh <snplist_file>

echo "=== Variant Counter ==="
echo ""

SNPLIST=$1  # Store first argument as variable

# Check if file argument was provided
if [ -z "$SNPLIST" ]; then
    echo "Error: No file specified"
    echo "Usage: $0 <snplist_file>"
    exit 1
fi

# Check if file exists
if [ ! -f "$SNPLIST" ]; then
    echo "Error: File not found: $SNPLIST"
    exit 1
fi

echo "Counting variants in: $SNPLIST"
echo ""

VARIANT_COUNT=$(wc -l < "$SNPLIST")  # Count lines in file

echo "Total variants: $VARIANT_COUNT"