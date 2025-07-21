import 'package:flutter_riverpod/flutter_riverpod.dart';

// Settings state class
class SettingsState {
  final bool autoSync;
  final bool showStockAlerts;
  final bool enableAddOns;
  final bool enableReceiptPrinting;
  final bool enableBackup;
  final String defaultCurrency;
  final String defaultLanguage;
  final Map<String, dynamic> receiptSettings;
  final Map<String, dynamic> backupSettings;
  final Map<String, dynamic> syncSettings;

  const SettingsState({
    this.autoSync = true,
    this.showStockAlerts = true,
    this.enableAddOns = true,
    this.enableReceiptPrinting = true,
    this.enableBackup = true,
    this.defaultCurrency = 'USD',
    this.defaultLanguage = 'en',
    this.receiptSettings = const {},
    this.backupSettings = const {},
    this.syncSettings = const {},
  });

  SettingsState copyWith({
    bool? autoSync,
    bool? showStockAlerts,
    bool? enableAddOns,
    bool? enableReceiptPrinting,
    bool? enableBackup,
    String? defaultCurrency,
    String? defaultLanguage,
    Map<String, dynamic>? receiptSettings,
    Map<String, dynamic>? backupSettings,
    Map<String, dynamic>? syncSettings,
  }) {
    return SettingsState(
      autoSync: autoSync ?? this.autoSync,
      showStockAlerts: showStockAlerts ?? this.showStockAlerts,
      enableAddOns: enableAddOns ?? this.enableAddOns,
      enableReceiptPrinting: enableReceiptPrinting ?? this.enableReceiptPrinting,
      enableBackup: enableBackup ?? this.enableBackup,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      receiptSettings: receiptSettings ?? this.receiptSettings,
      backupSettings: backupSettings ?? this.backupSettings,
      syncSettings: syncSettings ?? this.syncSettings,
    );
  }
}

// Settings notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    // Load settings from storage (mock for now)
    // In a real app, this would load from SharedPreferences or secure storage
  }

  Future<void> _saveSettings() async {
    // Save settings to storage (mock for now)
    // In a real app, this would save to SharedPreferences or secure storage
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Update auto sync setting
  Future<void> updateAutoSync(bool value) async {
    state = state.copyWith(autoSync: value);
    await _saveSettings();
  }

  // Update stock alerts setting
  Future<void> updateStockAlerts(bool value) async {
    state = state.copyWith(showStockAlerts: value);
    await _saveSettings();
  }

  // Update add-ons setting
  Future<void> updateAddOns(bool value) async {
    state = state.copyWith(enableAddOns: value);
    await _saveSettings();
  }

  // Update receipt printing setting
  Future<void> updateReceiptPrinting(bool value) async {
    state = state.copyWith(enableReceiptPrinting: value);
    await _saveSettings();
  }

  // Update backup setting
  Future<void> updateBackup(bool value) async {
    state = state.copyWith(enableBackup: value);
    await _saveSettings();
  }

  // Update default currency
  Future<void> updateDefaultCurrency(String currency) async {
    state = state.copyWith(defaultCurrency: currency);
    await _saveSettings();
  }

  // Update default language
  Future<void> updateDefaultLanguage(String language) async {
    state = state.copyWith(defaultLanguage: language);
    await _saveSettings();
  }

  // Update receipt settings
  Future<void> updateReceiptSettings(Map<String, dynamic> settings) async {
    state = state.copyWith(receiptSettings: settings);
    await _saveSettings();
  }

  // Update backup settings
  Future<void> updateBackupSettings(Map<String, dynamic> settings) async {
    state = state.copyWith(backupSettings: settings);
    await _saveSettings();
  }

  // Update sync settings
  Future<void> updateSyncSettings(Map<String, dynamic> settings) async {
    state = state.copyWith(syncSettings: settings);
    await _saveSettings();
  }

  // Reset all settings to defaults
  Future<void> resetToDefaults() async {
    state = const SettingsState();
    await _saveSettings();
  }
}

// Main settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);

// Individual setting providers for easy access
final autoSyncProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).autoSync;
});

final stockAlertsProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).showStockAlerts;
});

final addOnsProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).enableAddOns;
});

final receiptPrintingProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).enableReceiptPrinting;
});

final backupProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).enableBackup;
});

final currencyProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).defaultCurrency;
});

final languageProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).defaultLanguage;
});

final receiptSettingsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(settingsProvider).receiptSettings;
});

final backupSettingsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(settingsProvider).backupSettings;
});

final syncSettingsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(settingsProvider).syncSettings;
}); 