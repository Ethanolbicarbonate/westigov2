import 'package:flutter_riverpod/flutter_riverpod.dart';

// 0 = Map, 1 = Events, 2 = Favorites, 3 = Profile
final homeTabProvider = StateProvider<int>((ref) => 0);