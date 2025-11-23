import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigo/models/facility.dart';
import 'package:westigo/providers/search_provider.dart';
import 'package:westigo/screens/map/facility_detail_screen.dart';
import 'package:westigo/utils/constants.dart';
import 'package:westigo/models/space.dart';
import 'package:westigo/screens/map/space_detail_screen.dart';
import 'package:westigo/widgets/empty_state_widget.dart';
import 'package:westigo/utils/debouncer.dart'; // Import Debouncer

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _debouncer = Debouncer(milliseconds: 300); // Initialize Debouncer

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debouncer.dispose(); // Dispose Debouncer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
                        // Use Debouncer here
                        _debouncer.run(() {
                          ref.read(searchQueryProvider.notifier).state = value;
                        });
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

            Expanded(
              child: results.isEmpty && _searchController.text.isNotEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.search_off,
                      title: 'No results found',
                      subtitle: 'Try adjusting your search terms or look for a different facility.',
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: result.type == 'Facility'
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SpaceDetailScreen(
                                    space: space,
                                    parentFacilityName: 'See Facility Details',
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