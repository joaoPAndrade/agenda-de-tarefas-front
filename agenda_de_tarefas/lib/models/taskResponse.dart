import './task.dart';

class TaskResponse {
  int id;
  String title;
  String? comments;
  String description;
  String ownerEmail;
  DateTime dateCreation;
  DateTime dateTask;
  DateTime? dateConclusion;
  bool isRecurrent;
  Priority priority;
  Status status;
  int groupId;
  int categoryId;
  String groupName;
  String categoryName;

  TaskResponse({
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
    required this.groupName,
    required this.categoryName,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    return TaskResponse(
      id: json['id'],
      title: json['title'],
      comments: json['comments'], // Pode ser null
      description: json['description'],
      ownerEmail: json['ownerEmail'],
      dateCreation: DateTime.parse(json['dateCreation']),
      dateTask: DateTime.parse(json['dateTask']),
      dateConclusion: json['dateConclusion'] != null 
          ? DateTime.parse(json['dateConclusion']) 
          : null,
      isRecurrent: json['isRecurrent'],
      priority: Priority.fromString(json['priority']),
      status: Status.fromString(json['status']),
      groupId: json['groupId'],
      categoryId: json['categoryId'],
      groupName: json['groupName'],
      categoryName: json['categoryName'],
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
      'dateConclusion': dateConclusion?.toIso8601String(),
      'isRecurrent': isRecurrent,
      'priority': priority.name,
      'status': status.name,
      'groupId': groupId,
      'categoryId': categoryId,
      'groupName': groupName,
      'categoryName': categoryName,
    };
  }
}
