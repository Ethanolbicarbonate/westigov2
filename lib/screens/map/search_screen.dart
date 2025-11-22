import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/models/facility.dart';
import 'package:westigov2/providers/search_provider.dart';
import 'package:westigov2/screens/map/facility_detail_screen.dart';
import 'package:westigov2/utils/constants.dart';
import 'package:westigov2/models/space.dart'; // Import
import 'package:westigov2/screens/map/space_detail_screen.dart'; // Import

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the results
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Header
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      // Clear query when closing
                      ref.read(searchQueryProvider.notifier).state = '';
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Search facilities and spaces...',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        ref.read(searchQueryProvider.notifier).state = value;
                      },
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    ),
                ],
              ),
            ),

            // 2. Results List
            Expanded(
              child: results.isEmpty && _searchController.text.isNotEmpty
                  ? const Center(child: Text('No results found'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: result.type == 'Facility'
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            child: Icon(
                              result.type == 'Facility'
                                  ? Icons.business
                                  : Icons.meeting_room,
                              color: result.type == 'Facility'
                                  ? AppColors.primary
                                  : Colors.orange,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            result.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            result.type,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            if (result.type == 'Facility') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FacilityDetailScreen(
                                    facility: result.originalObject as Facility,
                                  ),
                                ),
                              );
                            } else {
                              final space = result.originalObject as Space;
                              // We try to infer parent name from description or just leave generic
                              // In a real app, we might fetch the parent facility name here

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SpaceDetailScreen(
                                    space: space,
                                    parentFacilityName:
                                        'See Facility Details', // Placeholder logic
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
