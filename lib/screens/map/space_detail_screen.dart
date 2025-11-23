import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigo/models/facility.dart';
import 'package:westigo/models/space.dart';
import 'package:westigo/providers/facility_provider.dart';
import 'package:westigo/screens/map/facility_detail_screen.dart';
import 'package:westigo/utils/constants.dart';
import 'package:westigo/widgets/favorite_button.dart';

class SpaceDetailScreen extends ConsumerStatefulWidget {
  final Space space;
  final String? parentFacilityName; 

  const SpaceDetailScreen({
    super.key, 
    required this.space,
    this.parentFacilityName,
  });

  @override
  ConsumerState<SpaceDetailScreen> createState() => _SpaceDetailScreenState();
}

class _SpaceDetailScreenState extends ConsumerState<SpaceDetailScreen> {
  Facility? _parentFacility;
  bool _isLoadingFacility = false;

  @override
  void initState() {
    super.initState();
    _fetchParentFacility();
  }

  Future<void> _fetchParentFacility() async {
    if (widget.space.parentFacilityId == null) return;

    setState(() => _isLoadingFacility = true);
    try {
      final service = ref.read(facilityServiceProvider);
      final facility = await service.getFacilityById(widget.space.parentFacilityId!);
      
      if (mounted) {
        setState(() {
          _parentFacility = facility;
        });
      }
    } catch (e) {
      print('Error fetching parent facility: $e');
    } finally {
      if (mounted) setState(() => _isLoadingFacility = false);
    }
  }

  void _navigateToFacility() {
    if (_parentFacility != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FacilityDetailScreen(facility: _parentFacility!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String locationText = 'Loading...';
    if (_parentFacility != null) {
      locationText = _parentFacility!.name;
    } else if (widget.parentFacilityName != null) {
      locationText = widget.parentFacilityName!;
    } else if (!_isLoadingFacility) {
      locationText = 'Unknown Facility';
    }

    final isLink = _parentFacility != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.space.name, style: const TextStyle(color: Colors.white)), // Force White
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white), // Force Back Button White
        actions: [
          FavoriteButton(type: 'space', id: widget.space.id),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.space.photoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                child: Image.network(
                  widget.space.photoUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(height: 200, color: Colors.grey[200]),
                ),
              ),
            
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: const [
                   BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.apartment, 
                    'Location', 
                    locationText, 
                    isLink: isLink,
                    onTap: isLink ? _navigateToFacility : null,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    Icons.layers, 
                    'Floor', 
                    widget.space.floorLevel ?? 'Unknown'
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (widget.space.description != null) ...[
              Text(
                'About',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.space.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLink = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded( // Added Expanded to prevent overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    value, 
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      // No underline, just color
                      color: isLink ? AppColors.primary : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (isLink) 
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}