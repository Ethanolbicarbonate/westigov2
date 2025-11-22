import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/providers/event_filter_provider.dart';
import 'package:westigov2/utils/constants.dart';

class EventFilterSheet extends ConsumerWidget {
  const EventFilterSheet({super.key});

  final List<String> _years = const ['1st years', '2nd years', '3rd years', '4th years'];
  final List<String> _colleges = const [
    'CICT', 'COE', 'CBM', 'CAS', 'COED', 'CPAG', 'CN', 'PESCAR', 'COM', 'COD', 'COL'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(eventFilterProvider);
    final notifier = ref.read(eventFilterProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // 75% height
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Events',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => notifier.clearAll(),
                child: const Text('Clear All'),
              ),
            ],
          ),
          const Divider(),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Year Level Section
                  const Text(
                    'Year Level',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _years.map((year) {
                      final isSelected = filterState.selectedYears.contains(year);
                      return FilterChip(
                        label: Text(year),
                        selected: isSelected,
                        onSelected: (_) => notifier.toggleYear(year),
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // College Section
                  const Text(
                    'College',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colleges.map((college) {
                      final isSelected = filterState.selectedColleges.contains(college);
                      return FilterChip(
                        label: Text(college),
                        selected: isSelected,
                        onSelected: (_) => notifier.toggleCollege(college),
                        selectedColor: Colors.green.withOpacity(0.2),
                        checkmarkColor: Colors.green,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.green : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Apply Button
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close sheet
              // Logic is reactive, so UI updates automatically
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Show Events'),
          ),
        ],
      ),
    );
  }
}