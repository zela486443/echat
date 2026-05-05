$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Echats Native APK Auto-Builder " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Android Studio exists! Checking Flutter SDK..." -ForegroundColor Yellow

$flutterPath = "C:\src\flutter\bin\flutter.bat"
$flutterDir = "C:\src\flutter"

if (-Not (Test-Path $flutterPath)) {
    Write-Host "Flutter SDK is missing. Downloading Flutter Stable directly to C:\src\..." -ForegroundColor Magenta
    if (-Not (Test-Path "C:\src")) { New-Item -ItemType Directory -Path "C:\src" | Out-Null }
    
    $zipPath = "C:\src\flutter_windows.zip"
    Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.3-stable.zip" -OutFile $zipPath
    
    Write-Host "Extracting Flutter SDK... (This might take a few minutes)" -ForegroundColor Yellow
    Expand-Archive -Path $zipPath -DestinationPath "C:\src" -Force
    Remove-Item $zipPath
    Write-Host "Flutter SDK Installed successfully!" -ForegroundColor Green
}

Write-Host "Accepting Android Licenses..." -ForegroundColor Yellow
$('y' * 20) | & $flutterPath doctor --android-licenses

Write-Host "Building the Echats APK..." -ForegroundColor Cyan
& $flutterPath create --platforms android .
& $flutterPath pub get
& $flutterPath build apk --release

Write-Host "==========================================" -ForegroundColor Green
Write-Host " BUILD COMPLETE! Your APK is ready! " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "You can find your new APK file at: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
