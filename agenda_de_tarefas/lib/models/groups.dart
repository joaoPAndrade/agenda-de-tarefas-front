class Group {
  int id;
  String name;
  String description;
  String ownerEmail;

  Group(
      {required this.id,
      required this.name,
      required this.description,
      required this.ownerEmail});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        ownerEmail: json['ownerEmail']);
  }
}