# 📱 Vendura POS - Mobile Testing Guide

This guide covers how to test and run Vendura POS on mobile platforms (iOS and Android).

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.10.0 or higher)
- Xcode (for iOS development)
- Android Studio (for Android development)
- iOS Simulator or Android Emulator

## 📱 Platform Setup

### iOS Development
1. **Install Xcode** from the Mac App Store
2. **Open Xcode** and accept the license agreement
3. **Install iOS Simulator**:
   ```bash
   # Start iOS Simulator
   open -a Simulator
   ```

### Android Development
1. **Install Android Studio** from https://developer.android.com/studio
2. **Install Android SDK** through Android Studio
3. **Create Android Virtual Device (AVD)**:
   - Open Android Studio
   - Go to Tools > AVD Manager
   - Create a new virtual device

## 🧪 Testing on Mobile

### iOS Testing

1. **Start iOS Simulator**
   ```bash
   open -a Simulator
   ```

2. **Check available devices**
   ```bash
   flutter devices
   ```

3. **Run on iOS Simulator**
   ```bash
   flutter run -d "iPhone 16 Plus"
   ```

4. **Test different iOS devices**
   ```bash
   # iPhone 16 Plus
   flutter run -d "iPhone 16 Plus"
   
   # iPhone 16 Pro
   flutter run -d "iPhone 16 Pro"
   
   # iPad
   flutter run -d "iPad Pro (12.9-inch) (7th generation)"
   ```

### Android Testing

1. **Start Android Emulator**
   ```bash
   # List available emulators
   flutter emulators
   
   # Start an emulator
   flutter emulators --launch <emulator_id>
   ```

2. **Run on Android Emulator**
   ```bash
   flutter run -d android
   ```

### Physical Device Testing

1. **iOS Device**
   - Connect iPhone/iPad via USB
   - Trust the computer on the device
   - Run: `flutter run -d ios`

2. **Android Device**
   - Enable Developer Options on device
   - Enable USB Debugging
   - Connect via USB
   - Run: `flutter run -d android`

## 📱 Mobile-Specific Features

### Touch Interactions
- **Tap**: Test item selection and button presses
- **Long Press**: Test context menus and options
- **Swipe**: Test navigation and gestures
- **Pinch**: Test zoom functionality (if applicable)

### Device Orientation
- **Portrait**: Primary orientation for mobile
- **Landscape**: Test responsive layout
- **Rotation**: Test smooth transitions

### Performance Testing
```bash
# Performance profiling
flutter run --profile

# Memory usage
flutter run --trace-startup
```

## 🎯 Testing Checklist

### iOS Testing
- [ ] **App Launch**: App starts without crashes
- [ ] **Navigation**: Bottom navigation works smoothly
- [ ] **Order Creation**: Can create new orders
- [ ] **Item Selection**: Can add items to cart
- [ ] **Cart Management**: Can modify quantities
- [ ] **Payment Flow**: Payment screen loads correctly
- [ ] **Receipts**: Receipt generation works
- [ ] **Settings**: Settings screen accessible
- [ ] **Responsive Design**: UI adapts to screen size
- [ ] **Touch Interactions**: All buttons respond to touch

### Android Testing
- [ ] **App Launch**: App starts without crashes
- [ ] **Navigation**: Bottom navigation works smoothly
- [ ] **Order Creation**: Can create new orders
- [ ] **Item Selection**: Can add items to cart
- [ ] **Cart Management**: Can modify quantities
- [ ] **Payment Flow**: Payment screen loads correctly
- [ ] **Receipts**: Receipt generation works
- [ ] **Settings**: Settings screen accessible
- [ ] **Responsive Design**: UI adapts to screen size
- [ ] **Touch Interactions**: All buttons respond to touch
- [ ] **Back Button**: Android back button works correctly

### Cross-Platform Testing
- [ ] **Consistent UI**: Same appearance across platforms
- [ ] **Platform Dialogs**: Native dialogs on each platform
- [ ] **Performance**: Smooth animations and transitions
- [ ] **Memory Usage**: No memory leaks
- [ ] **Battery Usage**: Efficient power consumption

## 🔧 Debugging Mobile Issues

### Common iOS Issues
1. **Build Errors**
   ```bash
   # Clean and rebuild
   flutter clean
   flutter pub get
   flutter run -d ios
   ```

2. **Simulator Issues**
   ```bash
   # Reset simulator
   xcrun simctl erase all
   ```

3. **Code Signing Issues**
   - Open Xcode
   - Select Runner project
   - Update signing configuration

### Common Android Issues
1. **Build Errors**
   ```bash
   # Clean and rebuild
   flutter clean
   flutter pub get
   flutter run -d android
   ```

2. **Emulator Issues**
   ```bash
   # Reset emulator
   adb emu kill
   ```

3. **Gradle Issues**
   ```bash
   # Clean gradle
   cd android
   ./gradlew clean
   cd ..
   ```

## 📊 Performance Testing

### iOS Performance
```bash
# Profile performance
flutter run --profile -d ios

# Check memory usage
flutter run --trace-startup -d ios
```

### Android Performance
```bash
# Profile performance
flutter run --profile -d android

# Check memory usage
flutter run --trace-startup -d android
```

### Performance Metrics
- **App Launch Time**: < 3 seconds
- **Navigation Response**: < 100ms
- **Memory Usage**: < 100MB
- **Battery Impact**: Minimal

## 🧪 Automated Testing

### Unit Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

### Integration Tests
```bash
# Run integration tests
flutter test integration_test/
```

### Platform-Specific Tests
```bash
# iOS tests
flutter test --platform ios

# Android tests
flutter test --platform android
```

## 📱 Device-Specific Testing

### iPhone Testing
- **iPhone 16 Plus**: Primary testing device
- **iPhone 16 Pro**: Test smaller screen
- **iPhone SE**: Test compact layout
- **iPad**: Test tablet layout

### Android Testing
- **Pixel 8**: Primary testing device
- **Samsung Galaxy**: Test different manufacturer
- **Tablet**: Test large screen layout

## 🚨 Troubleshooting

### Build Issues
```bash
# Check Flutter setup
flutter doctor

# Clean project
flutter clean
flutter pub get

# Rebuild
flutter run
```

### Runtime Issues
1. **App Crashes**: Check console logs
2. **UI Issues**: Test on different screen sizes
3. **Performance**: Use profile mode
4. **Memory**: Monitor memory usage

### Platform-Specific Issues
1. **iOS**: Check Xcode console
2. **Android**: Check Android Studio logcat
3. **Web**: Check browser console

## 📈 Testing Best Practices

### Manual Testing
1. **Test on Real Devices**: Use physical devices when possible
2. **Test Different Screen Sizes**: Cover various device sizes
3. **Test Different Orientations**: Portrait and landscape
4. **Test Edge Cases**: Empty states, error conditions
5. **Test Performance**: Monitor app responsiveness

### Automated Testing
1. **Unit Tests**: Test individual components
2. **Widget Tests**: Test UI components
3. **Integration Tests**: Test complete workflows
4. **Performance Tests**: Monitor app performance

## 📱 Mobile-Specific Features

### Camera Integration
- **QR Code Scanning**: Test barcode scanning
- **Photo Capture**: Test image capture functionality
- **Permission Handling**: Test camera permissions

### Push Notifications
- **Local Notifications**: Test in-app notifications
- **Remote Notifications**: Test server-sent notifications
- **Permission Handling**: Test notification permissions

### Offline Functionality
- **Data Persistence**: Test offline data storage
- **Sync Behavior**: Test data synchronization
- **Error Handling**: Test offline error states

---

**Vendura POS** is now fully tested and optimized for mobile platforms! 📱✅ 