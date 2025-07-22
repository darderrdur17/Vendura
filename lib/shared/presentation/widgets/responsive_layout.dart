import 'package:flutter/material.dart';
import 'package:vendura/core/services/platform_service.dart';
import 'package:vendura/core/theme/app_theme.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? web;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.web,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    // Web-specific layout
    if (PlatformService.isWeb) {
      if (web != null) return web!;
      
      if (size.width >= 1200) {
        return desktop ?? tablet ?? mobile;
      } else if (size.width >= 800) {
        return tablet ?? mobile;
      } else {
        return mobile;
      }
    }
    
    // Mobile/Desktop layout
    if (size.width >= 1200) {
      return desktop ?? tablet ?? mobile;
    } else if (size.width >= 800) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;
    final isTablet = size.width >= 800 && size.width < 1200;
    final isDesktop = size.width >= 1200;
    
    return builder(context, isMobile, isTablet, isDesktop);
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final EdgeInsets padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, isMobile, isTablet, isDesktop) {
        int crossAxisCount;
        
        if (PlatformService.isWeb) {
          if (isDesktop) {
            crossAxisCount = 6;
          } else if (isTablet) {
            crossAxisCount = 4;
          } else {
            crossAxisCount = 2;
          }
        } else {
          if (isDesktop) {
            crossAxisCount = 5;
          } else if (isTablet) {
            crossAxisCount = 3;
          } else {
            crossAxisCount = 2;
          }
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: runSpacing,
          padding: padding,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      },
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final BoxDecoration? decoration;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, isMobile, isTablet, isDesktop) {
        double containerMaxWidth;
        
        if (PlatformService.isWeb) {
          if (isDesktop) {
            containerMaxWidth = maxWidth ?? 1200;
          } else if (isTablet) {
            containerMaxWidth = maxWidth ?? 800;
          } else {
            containerMaxWidth = maxWidth ?? double.infinity;
          }
        } else {
          if (isDesktop) {
            containerMaxWidth = maxWidth ?? 1200;
          } else if (isTablet) {
            containerMaxWidth = maxWidth ?? 800;
          } else {
            containerMaxWidth = maxWidth ?? double.infinity;
          }
        }

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: containerMaxWidth),
          padding: padding ?? const EdgeInsets.all(AppTheme.spacingM),
          decoration: decoration,
          child: child,
        );
      },
    );
  }
}

class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, isMobile, isTablet, isDesktop) {
        if (PlatformService.isWeb && isDesktop) {
          // Desktop web app bar
          return AppBar(
            title: Text(
              title,
              style: AppTheme.titleLarge.copyWith(
                color: foregroundColor ?? Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: backgroundColor ?? AppTheme.primaryColor,
            foregroundColor: foregroundColor ?? Colors.white,
            elevation: elevation ?? 0,
            leading: leading,
            automaticallyImplyLeading: automaticallyImplyLeading,
            actions: actions,
            centerTitle: false,
          );
        } else {
          // Mobile/tablet app bar
          return AppBar(
            title: Text(
              title,
              style: AppTheme.titleMedium.copyWith(
                color: foregroundColor ?? Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: backgroundColor ?? AppTheme.primaryColor,
            foregroundColor: foregroundColor ?? Colors.white,
            elevation: elevation ?? 0,
            leading: leading,
            automaticallyImplyLeading: automaticallyImplyLeading,
            actions: actions,
            centerTitle: true,
          );
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 