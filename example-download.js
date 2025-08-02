// Example binary download implementation for Tauri app

const https = require('https');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { execSync } = require('child_process');

const GITHUB_REPO = 'leancuts/media-tools';
const MANIFEST_URL = `https://github.com/${GITHUB_REPO}/releases/download/v1.0.0/latest.json`;

async function downloadFile(url, destPath) {
    // Use curl for better redirect handling
    return new Promise((resolve, reject) => {
        try {
            execSync(`curl -L -o "${destPath}" "${url}"`, { stdio: 'inherit' });
            resolve();
        } catch (error) {
            reject(error);
        }
    });
}

async function verifyChecksum(filePath, expectedSha256) {
    return new Promise((resolve, reject) => {
        const hash = crypto.createHash('sha256');
        const stream = fs.createReadStream(filePath);
        
        stream.on('data', data => hash.update(data));
        stream.on('end', () => {
            const actualSha256 = hash.digest('hex');
            resolve(actualSha256 === expectedSha256);
        });
        stream.on('error', reject);
    });
}

async function downloadBinaries() {
    console.log('Downloading binary manifest...');
    
    // 1. Download manifest (or use local for testing)
    const manifestPath = 'latest.json';
    if (fs.existsSync('manifests/latest.json')) {
        // Use local manifest for testing
        fs.copyFileSync('manifests/latest.json', manifestPath);
        console.log('Using local manifest for testing');
    } else {
        await downloadFile(MANIFEST_URL, manifestPath);
    }
    
    // Check if download was successful
    if (!fs.existsSync(manifestPath)) {
        throw new Error('Failed to download manifest');
    }
    
    const manifestContent = fs.readFileSync(manifestPath, 'utf8');
    let manifest;
    try {
        manifest = JSON.parse(manifestContent);
    } catch (e) {
        console.error('Failed to parse manifest:', manifestContent);
        throw new Error('Invalid manifest format');
    }
    
    // 2. Determine platform
    const platform = process.platform === 'darwin' ? 'darwin-arm64' : 'win32-x64';
    console.log(`Platform detected: ${platform}`);
    
    // 3. Create binaries directory
    const binDir = path.join(process.cwd(), 'binaries');
    if (!fs.existsSync(binDir)) {
        fs.mkdirSync(binDir, { recursive: true });
    }
    
    // 4. Download each tool
    for (const [toolName, toolInfo] of Object.entries(manifest.tools)) {
        const platformInfo = toolInfo.platforms[platform];
        if (!platformInfo) {
            console.log(`No binary for ${toolName} on ${platform}`);
            continue;
        }
        
        console.log(`Downloading ${toolName}...`);
        const archivePath = path.join(binDir, `${toolName}.archive`);
        
        // Download
        await downloadFile(platformInfo.url, archivePath);
        
        // Verify checksum
        console.log(`Verifying ${toolName} checksum...`);
        const isValid = await verifyChecksum(archivePath, platformInfo.sha256);
        if (!isValid) {
            throw new Error(`Checksum verification failed for ${toolName}`);
        }
        
        // Extract
        console.log(`Extracting ${toolName}...`);
        if (platform === 'darwin-arm64') {
            execSync(`tar -xzf ${archivePath} -C ${binDir}`, { stdio: 'inherit' });
        } else {
            execSync(`unzip -o ${archivePath} -d ${binDir}`, { stdio: 'inherit' });
        }
        
        // Clean up archive
        fs.unlinkSync(archivePath);
        
        // Make executable on Unix
        if (platform === 'darwin-arm64') {
            const execPath = path.join(binDir, platformInfo.executable);
            fs.chmodSync(execPath, 0o755);
        }
    }
    
    console.log('All binaries downloaded successfully!');
    
    // Test binaries
    console.log('\nTesting binaries...');
    if (platform === 'darwin-arm64') {
        console.log('FFmpeg:', execSync(`${binDir}/ffmpeg -version | head -1`, { encoding: 'utf8' }).trim());
        console.log('ImageMagick:', execSync(`${binDir}/magick -version | head -1`, { encoding: 'utf8' }).trim());
        console.log('ExifTool:', execSync(`${binDir}/exiftool -ver`, { encoding: 'utf8' }).trim());
    }
}

// Run if called directly
if (require.main === module) {
    downloadBinaries().catch(console.error);
}

module.exports = { downloadBinaries };