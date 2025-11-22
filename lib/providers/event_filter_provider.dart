import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventFilterState {
  final List<String> selectedYears;
  final List<String> selectedColleges;

  EventFilterState({
    this.selectedYears = const [],
    this.selectedColleges = const [],
  });

  EventFilterState copyWith({
    List<String>? selectedYears,
    List<String>? selectedColleges,
  }) {
    return EventFilterState(
      selectedYears: selectedYears ?? this.selectedYears,
      selectedColleges: selectedColleges ?? this.selectedColleges,
    );
  }

  bool get hasFilters => selectedYears.isNotEmpty || selectedColleges.isNotEmpty;
}

class EventFilterNotifier extends StateNotifier<EventFilterState> {
  EventFilterNotifier() : super(EventFilterState());

  void toggleYear(String year) {
    final current = state.selectedYears;
    if (current.contains(year)) {
      state = state.copyWith(selectedYears: current.where((y) => y != year).toList());
    } else {
      state = state.copyWith(selectedYears: [...current, year]);
    }
  }

  void toggleCollege(String college) {
    final current = state.selectedColleges;
    if (current.contains(college)) {
      state = state.copyWith(selectedColleges: current.where((c) => c != college).toList());
    } else {
      state = state.copyWith(selectedColleges: [...current, college]);
    }
  }

  void clearAll() {
    state = EventFilterState();
  }
}

final eventFilterProvider = StateNotifierProvider<EventFilterNotifier, EventFilterState>((ref) {
  return EventFilterNotifier();
});