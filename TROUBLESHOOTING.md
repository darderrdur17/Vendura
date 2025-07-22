# 🔧 Vendura POS - Troubleshooting Guide

This guide covers common issues and their solutions when developing and running Vendura POS on different platforms.

## 🚨 Common Build Issues

### iOS Build Issues

#### 1. Framework 'Pods_Runner' not found
**Error**: `Framework 'Pods_Runner' not found`

**Solution**:
```bash
# Clean iOS dependencies
cd ios
rm -rf Pods Podfile.lock
cd ..

# Clean Flutter
flutter clean
flutter pub get

# Rebuild
flutter run -d ios
```

#### 2. Code Signing Issues
**Error**: `Code signing is required for product type 'Application'`

**Solution**:
1. Open Xcode
2. Select Runner project
3. Go to Signing & Capabilities
4. Select "Automatically manage signing"
5. Choose your team

#### 3. iOS Simulator Issues
**Error**: `No application found for TargetPlatform.ios`

**Solution**:
```bash
# Add iOS platform
flutter create --platforms ios .

# Clean and rebuild
flutter clean
flutter pub get
flutter run -d ios
```

### Android Build Issues

#### 1. Gradle Build Failed
**Error**: `Gradle task assembleDebug failed`

**Solution**:
```bash
# Clean Android build
cd android
./gradlew clean
cd ..

# Clean Flutter
flutter clean
flutter pub get

# Rebuild
flutter run -d android
```

#### 2. SDK Issues
**Error**: `Android SDK not found`

**Solution**:
1. Install Android Studio
2. Install Android SDK through Android Studio
3. Set ANDROID_HOME environment variable

#### 3. Emulator Issues
**Error**: `No emulator found`

**Solution**:
```bash
# List available emulators
flutter emulators

# Start an emulator
flutter emulators --launch <emulator_id>
```

### Web Build Issues

#### 1. Web Renderer Issues
**Error**: `Web renderer not found`

**Solution**:
```bash
# Use HTML renderer
flutter run -d chrome --web-renderer html

# Use CanvasKit renderer
flutter run -d chrome --web-renderer canvaskit
```

#### 2. PWA Issues
**Error**: `Service worker not found`

**Solution**:
```bash
# Build for production
flutter build web --release

# Serve with HTTPS (required for PWA)
python -m http.server 8000 --directory build/web
```

## 🔧 Runtime Issues

### App Crashes

#### 1. Null Safety Issues
**Error**: `Null check operator used on a null value`

**Solution**:
```dart
// Use null-aware operators
final value = nullableValue ?? defaultValue;

// Use conditional access
final length = list?.length ?? 0;
```

#### 2. Platform-Specific Issues
**Error**: `Platform not supported`

**Solution**:
```dart
import 'package:vendura/core/services/platform_service.dart';

if (PlatformService.isWeb) {
  // Web-specific code
} else if (PlatformService.isMobile) {
  // Mobile-specific code
}
```

### Performance Issues

#### 1. Slow App Launch
**Solution**:
```bash
# Profile startup
flutter run --trace-startup

# Use release mode
flutter run --release
```

#### 2. Memory Leaks
**Solution**:
```bash
# Profile memory usage
flutter run --profile

# Check for memory leaks
flutter run --trace-startup
```

## 🛠️ Development Issues

### Hot Reload Not Working

#### 1. State Management Issues
**Solution**:
```dart
// Use proper state management
class MyWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}
```

#### 2. Provider Issues
**Solution**:
```dart
// Wrap with ProviderScope
void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### Debugging Issues

#### 1. Console Not Showing
**Solution**:
```bash
# Enable verbose logging
flutter run -v

# Check device logs
flutter logs
```

#### 2. Breakpoints Not Working
**Solution**:
1. Use VS Code Flutter extension
2. Set breakpoints in VS Code
3. Use `debugPrint()` for logging

## 📱 Platform-Specific Issues

### iOS Issues

#### 1. Camera Permissions
**Error**: `Camera permission denied`

**Solution**:
1. Add camera usage description in `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes</string>
```

#### 2. Push Notifications
**Error**: `Push notification not working`

**Solution**:
1. Configure push notifications in Xcode
2. Add notification capabilities
3. Test on physical device

### Android Issues

#### 1. Permissions
**Error**: `Permission denied`

**Solution**:
1. Add permissions in `android/app/src/main/AndroidManifest.xml`
2. Request permissions at runtime
3. Handle permission callbacks

#### 2. Back Button
**Error**: `Back button not working`

**Solution**:
```dart
// Handle back button
WillPopScope(
  onWillPop: () async {
    // Custom back button logic
    return true;
  },
  child: Scaffold(...),
)
```

### Web Issues

#### 1. PWA Installation
**Error**: `PWA not installable`

**Solution**:
1. Ensure HTTPS is enabled
2. Check manifest.json is valid
3. Verify service worker is registered

#### 2. Browser Compatibility
**Error**: `Not working in certain browsers`

**Solution**:
1. Test on multiple browsers
2. Use polyfills for older browsers
3. Check browser console for errors

## 🔍 Debugging Commands

### Flutter Doctor
```bash
# Check Flutter setup
flutter doctor

# Detailed information
flutter doctor -v
```

### Device Information
```bash
# List available devices
flutter devices

# Check device details
flutter devices -v
```

### Build Information
```bash
# Check build configuration
flutter build apk --debug
flutter build ios --debug
flutter build web --debug
```

### Performance Analysis
```bash
# Analyze app size
flutter build apk --analyze-size
flutter build ios --analyze-size
flutter build web --analyze-size
```

## 🚨 Emergency Fixes

### Complete Reset
```bash
# Nuclear option - complete reset
flutter clean
rm -rf ios/Pods ios/Podfile.lock
rm -rf android/.gradle
flutter pub get
flutter run
```

### Platform Reset
```bash
# Reset specific platform
flutter create --platforms ios,android,web .
flutter clean
flutter pub get
flutter run
```

### Dependency Reset
```bash
# Reset all dependencies
rm pubspec.lock
flutter pub get
flutter run
```

## 📞 Getting Help

### Common Resources
1. **Flutter Documentation**: https://flutter.dev/docs
2. **Stack Overflow**: Search for Flutter issues
3. **GitHub Issues**: Check package repositories
4. **Flutter Community**: Discord and forums

### Debugging Steps
1. **Check Flutter Doctor**: `flutter doctor`
2. **Clean Project**: `flutter clean`
3. **Update Dependencies**: `flutter pub upgrade`
4. **Check Logs**: Use console output
5. **Test on Different Devices**: Try multiple platforms

### Reporting Issues
When reporting issues, include:
1. **Flutter Version**: `flutter --version`
2. **Platform**: iOS/Android/Web
3. **Device**: Simulator/Emulator/Physical
4. **Error Logs**: Complete error messages
5. **Steps to Reproduce**: Detailed steps

---

**Remember**: Most issues can be resolved with `flutter clean && flutter pub get`! 🔧✅ 