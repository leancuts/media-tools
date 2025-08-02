#!/bin/bash

set -e

cd "$(dirname "$0")/.."

echo "Generating checksums for binaries..."

# Function to calculate SHA256
calculate_sha256() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        shasum -a 256 "$1" | cut -d' ' -f1
    else
        sha256sum "$1" | cut -d' ' -f1
    fi
}

# Generate checksums for all binaries
{
    echo "# SHA256 Checksums for Media Tools Binaries"
    echo "# Generated on $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    echo ""
    
    echo "## macOS ARM64"
    echo "ffmpeg: $(calculate_sha256 binaries/darwin-arm64/ffmpeg)"
    echo "magick: $(calculate_sha256 binaries/darwin-arm64/magick)"
    echo "exiftool: $(calculate_sha256 binaries/darwin-arm64/exiftool)"
    echo ""
    
    echo "## Windows x64"
    echo "ffmpeg.exe: $(calculate_sha256 binaries/win32-x64/ffmpeg.exe)"
    echo "magick.exe: $(calculate_sha256 binaries/win32-x64/magick.exe)"
    echo "exiftool.bat: $(calculate_sha256 binaries/win32-x64/exiftool.bat)"
} > checksums.txt

echo "Checksums saved to checksums.txt"