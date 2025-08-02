// Simple binary download example for Leancuts (public repo version)

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const MANIFEST_URL = 'https://raw.githubusercontent.com/leancuts/media-tools/main/manifests/latest.json';

async function downloadBinaries() {
    console.log('🚀 Leancuts Binary Downloader');
    console.log('==============================\n');
    
    // 1. Download manifest
    console.log('📦 Downloading manifest...');
    execSync(`curl -sL "${MANIFEST_URL}" -o latest.json`);
    const manifest = JSON.parse(fs.readFileSync('latest.json', 'utf8'));
    console.log(`✅ Manifest version: ${manifest.version}\n`);
    
    // 2. Determine platform
    const platform = process.platform === 'darwin' ? 'darwin-arm64' : 'win32-x64';
    console.log(`🖥️  Platform: ${platform}\n`);
    
    // 3. Create binaries directory
    const binDir = path.join(process.cwd(), 'binaries');
    if (!fs.existsSync(binDir)) {
        fs.mkdirSync(binDir, { recursive: true });
    }
    
    // 4. Download each tool
    for (const [toolName, toolInfo] of Object.entries(manifest.tools)) {
        const platformInfo = toolInfo.platforms[platform];
        if (!platformInfo) {
            console.log(`⚠️  No ${toolName} binary for ${platform}`);
            continue;
        }
        
        console.log(`📥 Downloading ${toolName} v${toolInfo.version}...`);
        const archiveName = path.basename(platformInfo.url);
        const archivePath = path.join(binDir, archiveName);
        
        // Download with curl (shows progress)
        execSync(`curl -L "${platformInfo.url}" -o "${archivePath}"`, { stdio: 'inherit' });
        
        // Extract
        console.log(`📂 Extracting ${toolName}...`);
        if (platform === 'darwin-arm64') {
            execSync(`cd "${binDir}" && tar -xzf "${archiveName}"`, { stdio: 'inherit' });
        } else {
            execSync(`cd "${binDir}" && unzip -o "${archiveName}"`, { stdio: 'inherit' });
        }
        
        // Make executable on Unix
        if (platform === 'darwin-arm64') {
            const execPath = path.join(binDir, platformInfo.executable);
            if (fs.existsSync(execPath)) {
                fs.chmodSync(execPath, 0o755);
                console.log(`✅ ${toolName} ready at: ${execPath}`);
            }
        }
        
        // Clean up archive
        fs.unlinkSync(archivePath);
        console.log('');
    }
    
    // 5. Test binaries
    if (platform === 'darwin-arm64') {
        console.log('🧪 Testing binaries...\n');
        
        try {
            const ffmpegVersion = execSync(`${binDir}/ffmpeg -version | head -1`, { encoding: 'utf8' }).trim();
            console.log(`✅ FFmpeg: ${ffmpegVersion}`);
        } catch (e) {
            console.log('❌ FFmpeg test failed');
        }
        
        try {
            const magickVersion = execSync(`${binDir}/magick -version | head -1`, { encoding: 'utf8' }).trim();
            console.log(`✅ ImageMagick: ${magickVersion}`);
        } catch (e) {
            console.log('❌ ImageMagick test failed');
        }
        
        try {
            const exifVersion = execSync(`${binDir}/exiftool -ver`, { encoding: 'utf8' }).trim();
            console.log(`✅ ExifTool: v${exifVersion}`);
        } catch (e) {
            console.log('❌ ExifTool test failed');
        }
    }
    
    console.log('\n✨ All binaries downloaded successfully!');
    console.log(`📍 Location: ${binDir}`);
}

// Run if called directly
if (require.main === module) {
    downloadBinaries().catch(console.error);
}

module.exports = { downloadBinaries };