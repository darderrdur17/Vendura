# 🍵 Vendura - Professional Cafe Management App

A comprehensive Flutter-based cafe management application with advanced features for menu management, order processing, inventory tracking, and real-time synchronization. **Available on mobile (iOS/Android) and web platforms.**

## ✨ Features

### 🛍️ **Order Management**
- **Smart Order Processing**: Create orders with unique IDs (ORD-YYYYMMDD-XXXX)
- **Add-ons Support**: Comprehensive customization options for drinks and food
- **Real-time Cart**: Live cart updates with add-ons and pricing
- **Professional UI**: Modern, eye-catching design with gradients and animations
- **Cross-Platform**: Works seamlessly on mobile and web
- **Tip Input & Cash Change**: Accept tips and calculate change for cash payments

### 📋 **Menu Management**
- **Comprehensive Item Management**: Add, edit, delete menu items on the fly
- **Stock Management**: Real-time inventory tracking with low-stock alerts
- **Add-ons Builder**: Unlimited modifiers (size, milk type, extras), with quantity and availability
- **Category Organization**: Coffee, Food, Beverages, Tea with detailed add-ons
- **Inline Stock Editing**: Edit stock and min-stock directly from the menu list

### ⚙️ **Settings & Configuration**
- **Auto-Sync System**: All changes automatically synchronize across the app
- **Smart Feature Toggles**: Enable/disable features globally
- **Stock Alerts**: Configurable low stock notifications and thresholds
- **Receipt Settings**: Customizable receipt (cafe name, slogan, contact info, footer)
- **Backup & Restore**: Data backup and restoration capabilities

### 📊 **Inventory Management**
- **Real-time Stock Tracking**: Live inventory updates
- **Low Stock Alerts**: Automatic warnings for low inventory
- **Stock Overview**: Visual dashboard with stock statistics
- **Minimum Stock Levels**: Configurable alert thresholds
- **Quick Restock**: Add stock quantities in seconds
- **Adjust Stock Dialog**: Increase/decrease stock with quick actions
- **Stock History**: View adjustment history (stub)

### 💳 **Payment & Receipts**
- **Tip Input**: Accept optional tips at checkout
- **Cash Change Calculation**: Enter cash received and auto-calculate change
- **Receipt Generation**: Receipts include tip and change details
- **Customizable Receipt**: Cafe name, slogan, contact info, and footer

## 🌐 **Cross-Platform Support**

### 📱 Mobile (iOS/Android)
- **Native Performance**: Optimized for mobile devices
- **Touch-Optimized**: Large buttons and intuitive gestures
- **Offline-First**: Works without internet connection
- **Camera Integration**: QR code scanning and photo capture
- **Push Notifications**: Real-time alerts and updates

### 🌍 Web (Progressive Web App)
- **Responsive Design**: Adapts to desktop, tablet, and mobile browsers
- **PWA Features**: Installable as a native app
- **Offline Support**: Works without internet connection
- **Fast Loading**: Optimized for web performance
- **Cross-Browser**: Works on Chrome, Firefox, Safari, Edge

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd Vendura
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**

   **Mobile:**
   ```bash
   flutter run
   ```

   **Web:**
   ```bash
   flutter run -d chrome
   ```

   **Build for production:**
   ```bash
   # Mobile
   flutter build apk
   flutter build ios
   
   # Web
   flutter build web
   ```

## 🏗️ Architecture

### Cross-Platform Architecture
```
vendura/
├── lib/
│   ├── core/
│   │   ├── services/
│   │   │   ├── platform_service.dart    # Platform detection
│   │   │   └── ...
│   │   └── ...
│   ├── shared/
│   │   └── presentation/
│   │       └── widgets/
│   │           └── responsive_layout.dart # Responsive UI
│   └── ...
├── web/                                 # Web-specific files
│   ├── index.html                      # Web entry point
│   ├── manifest.json                   # PWA manifest
│   └── flutter_bootstrap.js           # Custom bootstrap
└── ...
```

### Platform-Specific Features
- **Mobile**: Camera access, push notifications, native dialogs
- **Web**: PWA installation, browser APIs, responsive design
- **Shared**: Core business logic, data models, UI components

## 📱 Platform Features

### Mobile Features
- ✅ **Camera Integration**: QR code scanning, photo capture
- ✅ **Push Notifications**: Real-time alerts
- ✅ **Native Dialogs**: Platform-specific UI components
- ✅ **Touch Optimization**: Gesture-based interactions
- ✅ **Offline Storage**: SQLite database
- ✅ **Background Sync**: Automatic data synchronization

### Web Features
- ✅ **Progressive Web App**: Installable as native app
- ✅ **Responsive Design**: Desktop, tablet, mobile layouts
- ✅ **Offline Support**: Service worker caching
- ✅ **Fast Loading**: Optimized bundle size
- ✅ **Cross-Browser**: Chrome, Firefox, Safari, Edge
- ✅ **PWA Features**: App-like experience

## 🎨 UI/UX Design

### Responsive Design
- **Mobile**: Touch-optimized with large buttons
- **Tablet**: Side-by-side layout with enhanced navigation
- **Desktop**: Multi-column grid with keyboard shortcuts
- **Web**: Adaptive layout with browser-specific optimizations

### Platform-Specific UI
- **Mobile**: Bottom navigation, swipe gestures, native dialogs
- **Web**: Top navigation, mouse interactions, browser dialogs
- **Shared**: Consistent branding and color scheme

## 🔧 Development

### Platform Detection
```dart
import 'package:vendura/core/services/platform_service.dart';

if (PlatformService.isWeb) {
  // Web-specific code
} else if (PlatformService.isMobile) {
  // Mobile-specific code
}
```

### Responsive Layout
```dart
import 'package:vendura/shared/presentation/widgets/responsive_layout.dart';

ResponsiveLayout(
  mobile: MobileWidget(),
  tablet: TabletWidget(),
  desktop: DesktopWidget(),
)
```

### Building for Different Platforms
```bash
# Mobile
flutter build apk --release
flutter build ios --release

# Web
flutter build web --release

# All platforms
flutter build --release
```

## 📊 Performance

### Mobile Optimization
- **Native Performance**: Direct platform APIs
- **Efficient Rendering**: Skia graphics engine
- **Memory Management**: Optimized for mobile devices
- **Battery Optimization**: Minimal background processing

### Web Optimization
- **Fast Loading**: Compressed assets and lazy loading
- **Caching**: Browser and service worker caching
- **Bundle Size**: Optimized JavaScript bundle
- **CDN Ready**: Static asset optimization

## 🚀 Deployment

### Mobile Deployment
- **Android**: Google Play Store, APK distribution
- **iOS**: App Store, TestFlight
- **Enterprise**: Internal distribution

### Web Deployment
- **Firebase Hosting**: Recommended for PWA features
- **Netlify**: Easy deployment with CI/CD
- **Vercel**: Fast deployment with edge functions
- **Custom Server**: Any web server supporting static files

See [WEB_DEPLOYMENT.md](WEB_DEPLOYMENT.md) for detailed web deployment instructions.

## 🧪 Testing

### Cross-Platform Testing
```bash
# Test on all platforms
flutter test

# Platform-specific testing
flutter test --platform chrome
flutter test --platform android
flutter test --platform ios
```

### Web Testing
```bash
# Test web-specific features
flutter test --platform chrome

# Performance testing
flutter build web --analyze-size
```

## 📈 Analytics

### Platform Analytics
- **Mobile**: Firebase Analytics, Crashlytics
- **Web**: Google Analytics, Web Vitals
- **Cross-Platform**: Custom analytics integration

## 🔒 Security

### Platform Security
- **Mobile**: App signing, certificate pinning
- **Web**: HTTPS, CSP headers, secure cookies
- **Shared**: Data encryption, secure storage

## 📚 Documentation

- [Setup Guide](SETUP.md)
- [Web Deployment](WEB_DEPLOYMENT.md)
- [Project Summary](PROJECT_SUMMARY.md)
- [Development Roadmap](ROADMAP.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test on multiple platforms
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Vendura POS** - Professional cafe management across all platforms. 🍵📱🌐 