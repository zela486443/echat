$flutterPath = "C:\src\flutter\bin\flutter.bat"

Write-Host "Configuring flutter..."
& $flutterPath config --no-analytics

Write-Host "Skipping create..."

Write-Host "Pub get..."
& $flutterPath pub get

Write-Host "Building APK..."
& $flutterPath build apk --release
