class Facility {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final List<String> features;
  final String location;
  final bool isAvailable;

  Facility({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.features,
    this.location = '',
    this.isAvailable = true,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'umum',
      features: List<String>.from(json['features'] ?? []),
      location: json['location'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'features': features,
      'location': location,
      'isAvailable': isAvailable,
    };
  }

  // Helper method to get short description
  String get shortDescription {
    if (description.length > 80) {
      return '${description.substring(0, 80)}...';
    }
    return description;
  }

  // Helper method to get features as string
  String get featuresText {
    if (features.isEmpty) return 'Tidak ada fitur khusus';
    return features.join(', ');
  }
}
