class Tips {
  final String title;
  final String description;

  Tips({required this.title, required this.description});

  factory Tips.fromJson(Map<String, dynamic> json) {
    return Tips(
      title: json['title'] ?? json['judul'] ?? '',
      description: json['description'] ?? json['deskripsi'] ?? '',
    );
  }
} 