class Favorite {
  final int id;
  final String userId;
  final String favoritableType; // 'facility', 'space', 'event'
  final int favoritableId;

  const Favorite({
    required this.id,
    required this.userId,
    required this.favoritableType,
    required this.favoritableId,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      favoritableType: json['favoritable_type'] as String,
      favoritableId: json['favoritable_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'favoritable_type': favoritableType,
      'favoritable_id': favoritableId,
    };
  }
}