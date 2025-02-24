enum Priority {
  LOW,
  MID,
  HIGH;

  static Priority fromString(String value) {
    return Priority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Priority.LOW,
    );
  }
}

enum Status {
  TODO,
  ONGOING,
  COMPLETED;

  static Status fromString(String value) {
    return Status.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Status.TODO,
    );
  }
}

class Task {
   int id;
   String title;
   String comments;
   String description;
   String ownerEmail;
   DateTime dateCreation;
   DateTime dateTask;
   DateTime dateConclusion;
   bool isRecurrent;
   Priority priority;
   Status status;
   int groupId;
   int categoryId;

   Task({
    required this.id,
    required this.title,
    required this.comments,
    required this.description,
    required this.ownerEmail,
    required this.dateCreation,
    required this.dateTask,
    required this.dateConclusion,
    required this.isRecurrent,
    required this.priority,
    required this.status,
    required this.groupId,
    required this.categoryId,
  });

  
  Task copyWith({
    int? id,
    String? title,
    String? comments,
    String? description,
    String? ownerEmail,
    DateTime? dateCreation,
    DateTime? dateTask,
    DateTime? dateConclusion,
    bool? isRecurrent,
    Priority? priority,
    Status? status,
    int? groupId,
    int? categoryId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      comments: comments ?? this.comments,
      description: description ?? this.description,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      dateCreation: dateCreation ?? this.dateCreation,
      dateTask: dateTask ?? this.dateTask,
      dateConclusion: dateConclusion ?? this.dateConclusion,
      isRecurrent: isRecurrent ?? this.isRecurrent,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      groupId: groupId ?? this.groupId,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'comments': comments,
      'description': description,
      'ownerEmail': ownerEmail,
      'dateCreation': dateCreation.toIso8601String(),
      'dateTask': dateTask.toIso8601String(),
      'dateConclusion': dateConclusion.toIso8601String(),
      'isRecurrent': isRecurrent,
      'priority': priority.name,
      'status': status.name,
      'groupId': groupId,
      'categoryId': categoryId,
    };
  }



  Map<String, dynamic> toJsonUpdate() {
    return {
      'ownerEmail': ownerEmail,
      'title': title,
      'description': description,
      'dateTask': dateTask.toUtc().toIso8601String(),
      'isRecurrent': isRecurrent,
      'priority': priority.name,  
      'status': status.name,
      'groupId': groupId,
      'categoryId': categoryId,
    };
  }
  Map<String, dynamic> toJsonCreate() {
    return {
      'ownerEmail': ownerEmail,
      'title': title,
      'description': description,
      'dateTask': dateTask.toUtc().toIso8601String(),
      'isRecurrent': isRecurrent,
      'priority': priority.name,  
      'status': status.name,
      'groupId': groupId,
      'categoryId': categoryId,
    };
  }




  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      comments: json['comments'],
      description: json['description'],
      ownerEmail: json['ownerEmail'],
      dateCreation: DateTime.parse(json['dateCreation']),
      dateTask: DateTime.parse(json['dateTask']),
      dateConclusion: DateTime.parse(json['dateConclusion']),
      isRecurrent: json['isRecurrent'],
      priority: Priority.fromString(json['priority']),
      status: Status.fromString(json['status']),
      groupId: json['groupId'],
      categoryId: json['categoryId'],
    );
  }
}
