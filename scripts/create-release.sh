#!/bin/bash

set -e

cd "$(dirname "$0")/.."

VERSION=${1:-"1.0.0"}
RELEASE_DIR="release-$VERSION"

echo "Creating release packages for version $VERSION..."

# Create release directory
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

# Package macOS ARM64 binaries
echo "Packaging macOS ARM64 binaries..."
tar -czf "$RELEASE_DIR/ffmpeg-darwin-arm64.tar.gz" -C binaries/darwin-arm64 ffmpeg
tar -czf "$RELEASE_DIR/imagemagick-darwin-arm64.tar.gz" -C binaries/darwin-arm64 magick
tar -czf "$RELEASE_DIR/exiftool-darwin-arm64.tar.gz" -C binaries/darwin-arm64 exiftool exiftool-dir

# Package Windows x64 binaries
echo "Packaging Windows x64 binaries..."
(cd binaries/win32-x64 && zip -r "../../$RELEASE_DIR/ffmpeg-win32-x64.zip" ffmpeg.exe)
(cd binaries/win32-x64 && zip -r "../../$RELEASE_DIR/imagemagick-win32-x64.zip" magick.exe)
(cd binaries/win32-x64 && zip -r "../../$RELEASE_DIR/exiftool-win32-x64.zip" exiftool.bat exiftool-dir)

# Copy manifest and checksums
cp manifests/latest.json "$RELEASE_DIR/"
cp checksums.txt "$RELEASE_DIR/"

# Create release notes
cat > "$RELEASE_DIR/RELEASE_NOTES.md" << EOF
# Media Tools Release v$VERSION

This release includes pre-compiled binaries for:

## Tools Included
- **FFmpeg 6.0** - Video/audio processing
- **ImageMagick 7.1.1-47** - Image manipulation
- **ExifTool 13.10** - Metadata extraction

## Platforms
- macOS ARM64 (Apple Silicon)
- Windows x64

## Installation
Download the appropriate archive for your platform and extract the binaries.

## License
See LICENSE-NOTICE.md for licensing information for each tool.
EOF

echo "Release packages created in $RELEASE_DIR/"
ls -la "$RELEASE_DIR/"