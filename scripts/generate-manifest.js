#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const BASE_URL = 'https://github.com/leancuts/media-tools/releases/download';
const VERSION = '1.0.0';

function getFileSize(filePath) {
    return fs.statSync(filePath).size;
}

function getFileSha256(filePath) {
    const fileBuffer = fs.readFileSync(filePath);
    const hashSum = crypto.createHash('sha256');
    hashSum.update(fileBuffer);
    return hashSum.digest('hex');
}

const manifest = {
    version: VERSION,
    updated: new Date().toISOString(),
    tools: {
        ffmpeg: {
            version: "6.0",
            platforms: {
                "darwin-arm64": {
                    url: `${BASE_URL}/v${VERSION}/ffmpeg-darwin-arm64.tar.gz`,
                    sha256: getFileSha256('./binaries/darwin-arm64/ffmpeg'),
                    size: getFileSize('./binaries/darwin-arm64/ffmpeg'),
                    executable: "ffmpeg"
                },
                "win32-x64": {
                    url: `${BASE_URL}/v${VERSION}/ffmpeg-win32-x64.zip`,
                    sha256: getFileSha256('./binaries/win32-x64/ffmpeg.exe'),
                    size: getFileSize('./binaries/win32-x64/ffmpeg.exe'),
                    executable: "ffmpeg.exe"
                }
            }
        },
        imagemagick: {
            version: "7.1.1-47",
            platforms: {
                "darwin-arm64": {
                    url: `${BASE_URL}/v${VERSION}/imagemagick-darwin-arm64.tar.gz`,
                    sha256: getFileSha256('./binaries/darwin-arm64/magick'),
                    size: getFileSize('./binaries/darwin-arm64/magick'),
                    executable: "magick"
                },
                "win32-x64": {
                    url: `${BASE_URL}/v${VERSION}/imagemagick-win32-x64.zip`,
                    sha256: getFileSha256('./binaries/win32-x64/magick.exe'),
                    size: getFileSize('./binaries/win32-x64/magick.exe'),
                    executable: "magick.exe"
                }
            }
        },
        exiftool: {
            version: "13.10",
            platforms: {
                "darwin-arm64": {
                    url: `${BASE_URL}/v${VERSION}/exiftool-darwin-arm64.tar.gz`,
                    sha256: getFileSha256('./binaries/darwin-arm64/exiftool'),
                    size: getFileSize('./binaries/darwin-arm64/exiftool'),
                    executable: "exiftool"
                },
                "win32-x64": {
                    url: `${BASE_URL}/v${VERSION}/exiftool-win32-x64.zip`,
                    sha256: getFileSha256('./binaries/win32-x64/exiftool.bat'),
                    size: getFileSize('./binaries/win32-x64/exiftool.bat'),
                    executable: "exiftool.bat"
                }
            }
        }
    }
};

// Write manifest
fs.writeFileSync('./manifests/latest.json', JSON.stringify(manifest, null, 2));
console.log('Manifest generated successfully at manifests/latest.json');
console.log(`Version: ${VERSION}`);