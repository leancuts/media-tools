#!/bin/bash

set -e

echo "Running media-tools test suite..."
echo "================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing: $test_name... "
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((TESTS_FAILED++))
    fi
}

# Test 1: Repository structure
run_test "Repository structure" "test -d manifests && test -d scripts && test -d binaries/darwin-arm64 && test -d binaries/win32-x64"

# Test 2: Binary presence
run_test "FFmpeg macOS binary" "test -f binaries/darwin-arm64/ffmpeg"
run_test "ImageMagick macOS binary" "test -f binaries/darwin-arm64/magick"
run_test "ExifTool macOS binary" "test -f binaries/darwin-arm64/exiftool"
run_test "FFmpeg Windows binary" "test -f binaries/win32-x64/ffmpeg.exe"
run_test "ImageMagick Windows binary" "test -f binaries/win32-x64/magick.exe"
run_test "ExifTool Windows binary" "test -f binaries/win32-x64/exiftool.bat"

# Test 3: Binary functionality (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    run_test "FFmpeg functionality" "binaries/darwin-arm64/ffmpeg -version | grep -q 'ffmpeg version'"
    run_test "ImageMagick functionality" "binaries/darwin-arm64/magick -version | grep -q 'ImageMagick'"
    run_test "ExifTool functionality" "binaries/darwin-arm64/exiftool -ver | grep -q '13.10'"
fi

# Test 4: Manifest validation
run_test "Manifest exists" "test -f manifests/latest.json"
run_test "Manifest valid JSON" "jq . manifests/latest.json > /dev/null"
run_test "Manifest has version" "jq -e '.version' manifests/latest.json > /dev/null"
run_test "Manifest has tools" "jq -e '.tools.ffmpeg' manifests/latest.json > /dev/null"

# Test 5: GitHub release
run_test "GitHub release exists" "gh release view v1.0.0 --repo leancuts/media-tools > /dev/null 2>&1"

# Test 6: Download simulation
echo -e "\nTesting download simulation..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download manifest
run_test "Download manifest" "curl -sL https://raw.githubusercontent.com/leancuts/media-tools/main/manifests/latest.json -o manifest.json"

# Parse a download URL
if [ -f manifest.json ]; then
    URL=$(jq -r '.tools.ffmpeg.platforms."darwin-arm64".url' manifest.json)
    run_test "Parse download URL" "test -n '$URL'"
fi

cd - > /dev/null
rm -rf "$TEMP_DIR"

# Test 7: License documentation
run_test "License notice exists" "test -f LICENSE-NOTICE.md"
run_test "README exists" "test -f README.md"

# Summary
echo -e "\n================================="
echo "Test Summary:"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed!${NC} 🎉"
    exit 0
else
    echo -e "\n${RED}Some tests failed!${NC}"
    exit 1
fi