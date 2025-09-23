@echo off
echo ========================================
echo    CheckMe App - APK Download Helper
echo ========================================
echo.

echo Building release APK...
flutter build apk --release

echo.
echo ========================================
echo    APK Build Complete!
echo ========================================
echo.
echo APK Location: build\app\outputs\flutter-apk\app-release.apk
echo File Size: ~49.4 MB
echo.
echo To install on your Android device:
echo 1. Copy the APK file to your device
echo 2. Enable "Install from Unknown Sources" in Android settings
echo 3. Tap the APK file to install
echo.
echo Press any key to open the APK folder...
pause >nul

start explorer build\app\outputs\flutter-apk\
