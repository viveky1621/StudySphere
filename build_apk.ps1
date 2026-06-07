# build_apk.ps1
Write-Host "==========================================="
Write-Host "📦 Building StudySphere AI APK"
Write-Host "==========================================="

cd frontend

# Check if Flutter is installed
$flutterExists = Get-Command flutter -ErrorAction SilentlyContinue

if ($flutterExists) {
    Write-Host "`n[1/3] Getting Flutter dependencies..."
    flutter pub get

    Write-Host "`n[2/3] Generating launcher icons and splash screen (if not done yet)..."
    flutter pub run flutter_launcher_icons
    flutter pub run flutter_native_splash:create

    Write-Host "`n[3/3] Building Release APK..."
    flutter build apk --release

    Write-Host "`n✅ Build Complete!"
    Write-Host "👉 You can find your APK file at: frontend\build\app\outputs\flutter-apk\app-release.apk"
    
    # Optionally open the folder in File Explorer
    Invoke-Item "build\app\outputs\flutter-apk\"
} else {
    Write-Host "`n❌ Error: Flutter SDK is not detected in your system PATH."
    Write-Host "Please ensure Flutter is installed and added to your environment variables to build the APK."
}

Write-Host "`nPress any key to exit..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
