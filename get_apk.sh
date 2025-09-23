#!/bin/bash

echo "========================================"
echo "   CheckMe App - APK Download Helper"
echo "========================================"
echo

echo "Building release APK..."
flutter build apk --release

echo
echo "========================================"
echo "   APK Build Complete!"
echo "========================================"
echo
echo "APK Location: build/app/outputs/flutter-apk/app-release.apk"
echo "File Size: ~49.4 MB"
echo
echo "To install on your Android device:"
echo "1. Copy the APK file to your device"
echo "2. Enable 'Install from Unknown Sources' in Android settings"
echo "3. Tap the APK file to install"
echo

# Open the APK folder (works on most systems)
if command -v xdg-open &> /dev/null; then
    xdg-open build/app/outputs/flutter-apk/
elif command -v open &> /dev/null; then
    open build/app/outputs/flutter-apk/
else
    echo "APK folder: build/app/outputs/flutter-apk/"
fi
