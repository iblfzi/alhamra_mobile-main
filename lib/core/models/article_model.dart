class Article {
  final String id;
  final String title;
  final String description;
  final String content;
  final String author;
  final String source;
  final String urlToImage;
  final String url;
  final DateTime publishedAt;
  final String category;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    required this.source,
    required this.urlToImage,
    required this.url,
    required this.publishedAt,
    this.category = 'general',
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? 'Unknown',
      source: json['source']?['name'] ?? 'Unknown Source',
      urlToImage: json['urlToImage'] ?? '',
      url: json['url'] ?? '',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      category: json['category'] ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'author': author,
      'source': {'name': source},
      'urlToImage': urlToImage,
      'url': url,
      'publishedAt': publishedAt.toIso8601String(),
      'category': category,
    };
  }

  // Helper method to get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  // Helper method to get short description
  String get shortDescription {
    if (description.length > 100) {
      return '${description.substring(0, 100)}...';
    }
    return description;
  }
}
