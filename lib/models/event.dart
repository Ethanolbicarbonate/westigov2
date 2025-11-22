class Event {
  final int id;
  final String name;
  final String? description;
  final int? locationId;
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;
  final List<String> scopes;

  const Event({
    required this.id,
    required this.name,
    this.description,
    this.locationId,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
    required this.scopes,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      locationId: json['location_id'] as int?,
      // Supabase sends dates as ISO 8601 strings
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      imageUrl: json['image_url'] as String?,
      // Handle array from DB
      scopes: List<String>.from(json['scopes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location_id': locationId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'image_url': imageUrl,
      'scopes': scopes,
    };
  }
}