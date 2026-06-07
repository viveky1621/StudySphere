# Setup Flutter and Build APK
Write-Host "Downloading Flutter SDK..."
curl.exe -L -o "C:\Users\vivek\flutter.zip" "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.44.0-stable.zip"

Write-Host "Extracting Flutter SDK..."
# Using 7zip or native expand archive, but expand-archive is slow for large files. Let's try tar since Windows 10 has tar.exe.
tar.exe -xf "C:\Users\vivek\flutter.zip" -C "C:\Users\vivek"

Remove-Item "C:\Users\vivek\flutter.zip"

Write-Host "Adding Flutter to Environment PATH..."
$env:Path += ";C:\Users\vivek\flutter\bin"

Write-Host "Running Flutter Precache..."
flutter precache

Write-Host "Disabling analytics and accepting licenses..."
flutter config --no-analytics
flutter doctor --android-licenses --accept

Write-Host "Building APK..."
cd c:\Users\vivek\.gemini\antigravity\scratch\studysphere_ai\frontend
flutter pub get
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
flutter build apk --release

Write-Host "Build finished!"
