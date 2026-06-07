# start_dev.ps1
Write-Host "==========================================="
Write-Host "🚀 Launching StudySphere AI Environment"
Write-Host "==========================================="

# Load environment variables from backend/.env if it exists
if (Test-Path "backend/.env") {
    Get-Content "backend/.env" | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
        $name, $value = $_.Split('=', 2)
        [System.Environment]::SetEnvironmentVariable($name.Trim(), $value.Trim().Trim('"').Trim("'"), "Process")
    }
}

# Setup Backend
Write-Host "`n[1/4] Installing Backend Dependencies..."
cd backend
# Use npm.cmd to avoid execution policy restrictions on Windows
npm.cmd install

if ($env:MOCK_DATABASE -eq "true") {
    Write-Host "`n🔌 Standalone In-Memory Mock Database mode is active."
    Write-Host "👉 Skipping PostgreSQL database schema sync."
} else {
    Write-Host "`n[2/4] Syncing PostgreSQL Database Schema..."
    # Note: Ensure your local PostgreSQL is running and DATABASE_URL is set in backend/.env
    npx.cmd prisma db push
}

Write-Host "`n[3/4] Launching Backend Server in a new window..."
Start-Process cmd -ArgumentList "/c title StudySphere Backend && npm run dev"

# Setup Frontend
cd ../frontend

# Check if Flutter is installed on the system
$flutterExists = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutterExists) {
    Write-Host "`n[4/4] Installing Frontend Dependencies & Launching App..."
    flutter pub get
    
    Write-Host "`n🚀 Launching Flutter in a new window..."
    # Opening Flutter in a new command prompt so the user can use 'r' to hot-reload
    Start-Process cmd -ArgumentList "/k title StudySphere Frontend && flutter run"
    Write-Host "`n✅ All processes have been launched in separate windows!"
} else {
    Write-Host "`n[4/4] Skipping Frontend Launch..."
    Write-Host "⚠️  Flutter SDK was not detected in your system PATH."
    Write-Host "👉 To run the mobile app, please install Flutter and add it to your system PATH."
    Write-Host "`n✅ Express Backend launched successfully on http://localhost:3000!"
}

