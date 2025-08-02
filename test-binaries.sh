#!/bin/bash

set -e

echo "Testing media-tools binaries..."
echo "==============================="

# Test macOS binaries
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Testing macOS ARM64 binaries..."
    
    echo -n "FFmpeg: "
    ./binaries/darwin-arm64/ffmpeg -version | head -1
    
    echo -n "ImageMagick: "
    ./binaries/darwin-arm64/magick -version | head -1
    
    echo -n "ExifTool: "
    ./binaries/darwin-arm64/exiftool -ver
fi

# Test manifest
echo -e "\nChecking manifest..."
if [ -f "manifests/latest.json" ]; then
    echo "✓ Manifest exists"
    jq '.version' manifests/latest.json
else
    echo "✗ Manifest missing"
    exit 1
fi

# Test checksums
echo -e "\nVerifying checksums..."
if [ -f "checksums.txt" ]; then
    echo "✓ Checksums file exists"
else
    echo "✗ Checksums file missing"
    exit 1
fi

echo -e "\n✓ All tests passed!"