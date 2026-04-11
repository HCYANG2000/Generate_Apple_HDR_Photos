#!/bin/bash
# compress.sh — Batch-convert HDR images to 10-bit HEIC using HDR_iOS17.swift
# Requires macOS 14 (Sonoma) or later · Swift 5.9+

print_usage() {
    echo "Usage: bash compress.sh <directory> <quality> <mode> [threads]"
    echo ""
    echo "Arguments:"
    echo "  directory  Folder containing source images"
    echo "  quality    Compression quality from 0.1 to 1.0  (e.g. 0.85)"
    echo "  mode       Export mode:"
    echo "               1  8-bit  HEIF · Display P3  · compressed   (SDR)"
    echo "               2  8-bit  HEIF · Display P3  · lossless     (SDR)"
    echo "               3  10-bit HEIF · Display P3  · compressed   (wide-gamut SDR)"
    echo "               4  10-bit HEIF · Display P3  · lossless     (wide-gamut SDR)"
    echo "               5  10-bit HEIF · BT.2100 HLG · lossless    (HDR — recommended)"
    echo "               6  10-bit HEIF · BT.2100 PQ  · compressed  (HDR)"
    echo "               7  10-bit HEIF · HLG from RAW              (HDR from RAW)"
    echo "               8  10-bit HEIF · PQ  from RAW              (HDR from RAW)"
    echo "  threads    Parallel jobs (default: 4)"
    echo ""
    echo "Output: HEIC files are saved to <directory>/heic/"
    echo ""
    echo "Examples:"
    echo "  bash compress.sh ./photos 0.85 5"
    echo "  bash compress.sh ./raw_files 1.0 7 8"
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    print_usage
    exit 0
fi

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
    echo "Error: Expected 3 or 4 arguments, got $#."
    echo ""
    print_usage
    exit 1
fi

DIR="$1"
QUALITY="$2"
MODE="$3"
THREADS="${4:-4}"

if [ ! -d "$DIR" ]; then
    echo "Error: '$DIR' is not a directory."
    exit 1
fi

# Validate quality (must be a number in (0, 1])
if ! echo "$QUALITY" | grep -qE '^(0\.[0-9]+|1(\.0*)?)$'; then
    echo "Error: <quality> must be a number between 0.1 and 1.0 (got '$QUALITY')."
    exit 1
fi

# Validate mode
if ! echo "$MODE" | grep -qE '^[1-8]$'; then
    echo "Error: <mode> must be an integer from 1 to 8 (got '$MODE')."
    echo ""
    print_usage
    exit 1
fi

OUTDIR="$DIR/heic"
mkdir -p "$OUTDIR"

process_file() {
    local file="$1"
    local quality="$2"
    local mode="$3"
    local outdir="$4"
    local filename="${file##*/}"
    local basename="${filename%.*}"
    local output="$outdir/${basename}_hdr.heic"
    echo "  $filename → ${basename}_hdr.heic"
    swift HDR_iOS17.swift "$file" "$output" "$quality" "$mode"
}

export -f process_file

echo "Source : $DIR"
echo "Output : $OUTDIR"
echo "Quality: $QUALITY  Mode: $MODE  Threads: $THREADS"
echo ""

# Process supported image formats only (skip files in subdirectories)
find "$DIR" -maxdepth 1 -type f \( \
    -iname "*.tif"  -o -iname "*.tiff" \
    -o -iname "*.jpg"  -o -iname "*.jpeg" \
    -o -iname "*.png" \
    -o -iname "*.avif" \
    -o -iname "*.heic" \
    -o -iname "*.dng"  -o -iname "*.arw" \
    -o -iname "*.cr2"  -o -iname "*.cr3" \
    -o -iname "*.nef"  -o -iname "*.raf" \
\) | sort | xargs -I{} -P "$THREADS" bash -c \
    'process_file "$1" "$2" "$3" "$4"' _ {} "$QUALITY" "$MODE" "$OUTDIR"

echo ""
echo "Done. Output saved to: $OUTDIR"
