class Facility {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? description;
  final String? photoUrl;

  const Facility({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
    this.photoUrl,
  });

  // Factory constructor to create a Facility from JSON (Supabase response)
  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'] as int,
      name: json['name'] as String,
      // Handle potential int/double mismatch from JSON
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String?,
      photoUrl: json['photo_url'] as String?, // Note snake_case from DB
    );
  }

  // Convert Facility to JSON (for sending to Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'photo_url': photoUrl,
    };
  }

  // Helper to create a copy with modified fields
  Facility copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    String? description,
    String? photoUrl,
  }) {
    return Facility(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}