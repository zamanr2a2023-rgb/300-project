import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom navigation index inside [DashboardShell]: 0 Home, 1 Learn, 2 Stats, 3 You.
final panedDashboardTabIndexProvider = StateProvider<int>((ref) => 0);
