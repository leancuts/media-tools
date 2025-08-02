#!/bin/bash

set -e

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "Downloading binaries to temporary directory: $TEMP_DIR"

# Function to calculate SHA256
calculate_sha256() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        shasum -a 256 "$1" | cut -d' ' -f1
    else
        sha256sum "$1" | cut -d' ' -f1
    fi
}

# FFmpeg for macOS ARM64
echo "Downloading FFmpeg for macOS ARM64..."
curl -L -o ffmpeg-macos.zip "https://www.osxexperts.net/ffmpeg7_aarm64.zip" || {
    # Alternative source
    echo "Trying alternative source..."
    curl -L -o ffmpeg-macos.zip "https://github.com/eugeneware/ffmpeg-static/releases/download/b6.0/ffmpeg-darwin-arm64.gz"
    gunzip ffmpeg-macos.zip
    mv ffmpeg-macos ffmpeg
    chmod +x ffmpeg
}

# FFmpeg for Windows x64
echo "Downloading FFmpeg for Windows x64..."
curl -L -o ffmpeg-windows.zip "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"

# ImageMagick for macOS ARM64
echo "Downloading ImageMagick for macOS ARM64..."
# We'll need to build from source or find a pre-built binary
# For now, let's try homebrew bottles
IMAGEMAGICK_MAC_URL="https://ghcr.io/v2/homebrew/core/imagemagick/blobs/sha256:$(curl -s https://formulae.brew.sh/api/formula/imagemagick.json | jq -r '.bottle.stable.files.arm64_sonoma.sha256')"

# ImageMagick for Windows x64
echo "Downloading ImageMagick for Windows x64..."
curl -L -o imagemagick-windows.zip "https://imagemagick.org/archive/binaries/ImageMagick-7.1.1-39-portable-Q16-HDRI-x64.zip"

# ExifTool (platform independent)
echo "Downloading ExifTool..."
curl -L -o "Image-ExifTool-13.00.tar.gz" "https://exiftool.org/Image-ExifTool-13.00.tar.gz"

echo "Downloads complete. Files in: $TEMP_DIR"
ls -la