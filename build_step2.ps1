$flutterPath = "C:\src\flutter\bin\flutter.bat"

Write-Host "Accepting Licenses..."
1..15 | ForEach-Object { "y" } | & $flutterPath doctor --android-licenses

Write-Host "Creating platform files..."
& $flutterPath create --platforms android .

Write-Host "Pub get..."
& $flutterPath pub get

Write-Host "Building APK..."
& $flutterPath build apk --release
