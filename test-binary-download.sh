#!/bin/bash

set -e

echo "🧪 Testing binary repository download and functionality..."
echo "================================================="

# Create test directory
TEST_DIR="test-binaries-$(date +%s)"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "📦 Downloading manifest..."
gh release download v1.0.0 --repo leancuts/media-tools -p latest.json

echo "📄 Manifest contents:"
cat latest.json | jq .

echo -e "\n🔽 Downloading FFmpeg for macOS..."
URL=$(jq -r '.tools.ffmpeg.platforms."darwin-arm64".url' latest.json)
EXPECTED_SHA=$(jq -r '.tools.ffmpeg.platforms."darwin-arm64".sha256' latest.json)

# Download using gh (authenticated)
gh release download v1.0.0 --repo leancuts/media-tools -p ffmpeg-darwin-arm64.tar.gz

echo "🔍 Verifying checksum..."
ACTUAL_SHA=$(shasum -a 256 ffmpeg-darwin-arm64.tar.gz | cut -d' ' -f1)
if [ "$ACTUAL_SHA" = "$EXPECTED_SHA" ]; then
    echo "✅ Checksum verified!"
else
    echo "❌ Checksum mismatch!"
    echo "Expected: $EXPECTED_SHA"
    echo "Actual: $ACTUAL_SHA"
fi

echo -e "\n📦 Extracting binary..."
tar -xzf ffmpeg-darwin-arm64.tar.gz
ls -la

echo -e "\n🚀 Testing FFmpeg..."
./ffmpeg -version | head -3

echo -e "\n🎯 Running a simple conversion test..."
# Create a test video
./ffmpeg -f lavfi -i testsrc=duration=1:size=320x240:rate=30 -pix_fmt yuv420p test_input.mp4 2>/dev/null

# Convert it
./ffmpeg -i test_input.mp4 -vf scale=160:120 -c:v libx264 test_output.mp4 -y 2>/dev/null

if [ -f test_output.mp4 ]; then
    echo "✅ Conversion successful!"
    ls -la test_*.mp4
else
    echo "❌ Conversion failed!"
fi

echo -e "\n🧹 Cleaning up..."
cd ..
rm -rf "$TEST_DIR"

echo -e "\n✨ Binary repository test complete!"