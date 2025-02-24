class Category {
   int id;
   String name;
   String ownerEmail;

  Category({
    required this.id,
    required this.name,
    required this.ownerEmail,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      ownerEmail: json['ownerEmail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerEmail': ownerEmail,
    };
  }
}


