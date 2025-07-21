# 🍵 Vendura - Professional Cafe Management App

A comprehensive Flutter-based cafe management application with advanced features for menu management, order processing, inventory tracking, and real-time synchronization.

## ✨ Features

### 🛍️ **Order Management**
- **Smart Order Processing**: Create orders with unique IDs (ORD-YYYYMMDD-XXXX)
- **Add-ons Support**: Comprehensive customization options for drinks and food
- **Real-time Cart**: Live cart updates with add-ons and pricing
- **Professional UI**: Modern, eye-catching design with gradients and animations

### 📋 **Menu Management**
- **Comprehensive Item Management**: Add, edit, and organize menu items
- **Stock Management**: Real-time inventory tracking with low stock alerts
- **Add-ons System**: Full CRUD operations for item customizations
- **Category Organization**: Coffee, Food, Beverages, Tea with detailed add-ons

### ⚙️ **Settings & Configuration**
- **Auto-Sync System**: All changes automatically synchronize across the app
- **Smart Feature Toggles**: Enable/disable features globally
- **Stock Alerts**: Configurable low stock notifications
- **Receipt Settings**: Customizable receipt printing options
- **Backup & Restore**: Data backup and restoration capabilities

### 📊 **Inventory Management**
- **Real-time Stock Tracking**: Live inventory updates
- **Low Stock Alerts**: Automatic warnings for low inventory
- **Stock Overview**: Visual dashboard with stock statistics
- **Minimum Stock Levels**: Configurable alert thresholds

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
   ```bash
   flutter run
   ```

## 🏗️ Architecture

### **State Management**
- **Riverpod**: Modern state management with providers
- **Provider Pattern**: Clean separation of concerns
- **Reactive UI**: Real-time updates across all screens

### **Key Components**
- **Mock Service**: Simulated backend for development
- **Settings Provider**: Centralized configuration management
- **Items Provider**: Menu and inventory state management
- **Order Provider**: Cart and order processing

### **File Structure**
```
lib/
├── core/
│   ├── providers/          # State management
│   ├── services/          # Business logic
│   └── theme/             # UI theming
├── data/
│   └── models/            # Data models
├── features/
│   ├── orders/            # Order management
│   └── settings/          # Settings & configuration
└── shared/
    └── presentation/      # Shared UI components
```

## 🎨 UI/UX Features

### **Modern Design**
- **Professional Color Palette**: Blue-gray theme with accent colors
- **Gradient Backgrounds**: Eye-catching visual elements
- **Consistent Spacing**: AppTheme-based spacing system
- **Shadow Effects**: Depth and visual hierarchy

### **User Experience**
- **Intuitive Navigation**: Bottom navigation with clear sections
- **Real-time Feedback**: Success/error messages for all actions
- **Responsive Design**: Adapts to different screen sizes
- **Accessibility**: Clear visual indicators and labels

## 🔧 Configuration

### **Settings Management**
The app includes a comprehensive settings system with:

- **Auto Sync**: Master toggle for all synchronization
- **Stock Alerts**: Enable/disable low stock notifications
- **Add-ons**: Global toggle for item customization
- **Receipt Printing**: Automatic receipt generation
- **Auto Backup**: Automatic data backup

### **Add-ons Categories**
- **Coffee Add-ons**: Extra shots, syrups, milk options
- **Syrups**: Vanilla, caramel, hazelnut, etc.
- **Milk Substitutes**: Almond, soy, oat milk
- **Food Add-ons**: Extra toppings, sauces, sides
- **Toppings**: Whipped cream, sprinkles, nuts
- **Sweeteners**: Sugar, honey, artificial sweeteners

## 📱 Screenshots

*[Screenshots would be added here]*

## 🛠️ Development

### **Adding New Features**
1. Create feature-specific providers in `lib/core/providers/`
2. Add UI components in `lib/features/[feature-name]/`
3. Update navigation in `lib/shared/presentation/screens/main_screen.dart`
4. Test with `flutter test`

### **State Management**
```dart
// Example: Adding a new provider
final newFeatureProvider = StateNotifierProvider<NewFeatureNotifier, NewFeatureState>(
  (ref) => NewFeatureNotifier(),
);
```

### **Theming**
```dart
// Example: Adding new theme colors
class AppTheme {
  static const Color newColor = Color(0xFF123456);
  // ... other theme properties
}
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- The cafe management community for inspiration

## 📞 Support

For support, email support@vendura.com or create an issue in this repository.

---

**Made with ❤️ for cafe owners and baristas everywhere** 