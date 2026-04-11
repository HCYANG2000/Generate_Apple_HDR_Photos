#!/bin/bash
# hdr_bash.sh — Example script: sweep quality levels for comparison
# Useful for finding the best quality/file-size trade-off before batch processing.
# Edit the filenames and modes below to match your images.

SWIFT_SCRIPT="HDR_iOS17.swift"

# ── Non-HDR example ────────────────────────────────────────────────────────────
# Mode 1: 8-bit HEIF, Display P3, compressed
# Quality sweep from 0.3 to 1.0 in steps of 0.1

echo "=== Non-HDR sweep: 8-bit HEIF Display P3, quality 0.3–1.0 ==="
for step in $(seq 3 1 10); do
    input="Example_NonHDR.tif"
    quality="0.$step"
    label=$(printf "%02d" "$step")
    output="Example_NonHDR_q${label}.heic"
    echo "  quality $quality → $output"
    swift "$SWIFT_SCRIPT" "$input" "$output" "$quality" "1"
done

echo ""

# ── HDR example ────────────────────────────────────────────────────────────────
# Mode 6: 10-bit HEIF, BT.2100 PQ, compressed
# Quality sweep from 0.60 to 1.00 in steps of 0.05
# Note: quality below 0.75 may lose HDR detail — check file sizes

echo "=== HDR sweep: 10-bit HEIF BT.2100 PQ, quality 0.60–1.00 ==="
for step in 60 65 70 75 80 85 90 95 100; do
    input="Example_HDR.tif"
    # Convert integer step to decimal quality (e.g. 85 → 0.85)
    quality=$(printf "0.%02d" "$step" | sed 's/0\.10/1.00/')
    [ "$step" -eq 100 ] && quality="1.0"
    label=$(printf "%03d" "$step")
    output="Example_HDR_q${label}.heic"
    echo "  quality $quality → $output"
    swift "$SWIFT_SCRIPT" "$input" "$output" "$quality" "6"
done
