import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class PlatformService {
  static bool get isWeb => kIsWeb;
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Get the current platform name
  static String get platformName {
    if (isWeb) return 'Web';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Check if the device has a camera
  static bool get hasCamera {
    if (isWeb) {
      // For web, we'll assume camera is available
      return true;
    }
    // For mobile, we'll assume camera is available
    return isMobile;
  }

  /// Check if the device supports printing
  static bool get supportsPrinting {
    if (isWeb) {
      // Web supports printing via browser
      return true;
    }
    // Mobile supports printing via plugins
    return true;
  }

  /// Get optimal screen size for the platform
  static Size getOptimalScreenSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    if (isWeb) {
      // For web, use responsive design
      if (size.width > 1200) {
        return const Size(1200, 800);
      } else if (size.width > 800) {
        return const Size(800, 600);
      } else {
        return Size(size.width, size.height);
      }
    }
    
    // For mobile, use full screen
    return size;
  }

  /// Get optimal grid cross axis count for the platform
  static int getOptimalGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (isWeb) {
      if (width > 1200) return 6;
      if (width > 800) return 4;
      if (width > 600) return 3;
      return 2;
    }
    
    // For mobile
    if (width > 600) return 3;
    return 2;
  }

  /// Get optimal button size for the platform
  static Size getOptimalButtonSize(BuildContext context) {
    if (isWeb) {
      return const Size(120, 48);
    }
    return const Size(100, 44);
  }

  /// Show platform-specific dialog
  static Future<T?> showPlatformDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    if (isWeb) {
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => child,
      );
    }
    
    // For mobile, use full screen dialog
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  /// Copy text to clipboard
  static Future<void> copyToClipboard(String text) async {
    if (isWeb) {
      html.window.navigator.clipboard?.writeText(text);
    } else {
      // For mobile, use clipboard plugin
      // You can add clipboard_plus package for better support
    }
  }

  /// Share content
  static Future<void> shareContent(String text, {String? subject}) async {
    if (isWeb) {
      // For web, use navigator.share if available
      if (html.window.navigator.share != null) {
        await html.window.navigator.share!({
          'text': text,
          if (subject != null) 'title': subject,
        });
      } else {
        // Fallback to clipboard
        await copyToClipboard(text);
      }
    } else {
      // For mobile, use share_plus package
      // You can add share_plus package for better support
    }
  }

  /// Get device info for display
  static String getDeviceInfo() {
    if (isWeb) {
      return 'Web Browser';
    }
    return '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
  }

  /// Check if the app is running in debug mode
  static bool get isDebugMode => kDebugMode;

  /// Get the app version
  static String get appVersion => '1.0.0';

  /// Get the build number
  static String get buildNumber => '1';

  /// Check if the device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if the device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get the safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get the screen density
  static double getScreenDensity(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Check if the device has a notch
  static bool hasNotch(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return padding.top > 20 || padding.bottom > 0;
  }
} 