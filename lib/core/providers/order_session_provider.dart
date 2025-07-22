import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple counter that increments whenever a new order session should start.
final orderSessionProvider = StateProvider<int>((ref) => 0); 