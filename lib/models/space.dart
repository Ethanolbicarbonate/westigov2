class Space {
  final int id;
  final String name;
  final String? description;
  final int? parentFacilityId;
  final String? floorLevel;
  final String? photoUrl;

  const Space({
    required this.id,
    required this.name,
    this.description,
    this.parentFacilityId,
    this.floorLevel,
    this.photoUrl,
  });

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      parentFacilityId: json['parent_facility_id'] as int?,
      floorLevel: json['floor_level'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parent_facility_id': parentFacilityId,
      'floor_level': floorLevel,
      'photo_url': photoUrl,
    };
  }
}