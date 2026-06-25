import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime dueDate;
  final String priority; // 'Low', 'Medium', 'High'
  final bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Work',
      dueDate: data['dueDate'] is Timestamp 
          ? (data['dueDate'] as Timestamp).toDate()
          : DateTime.now(),
      priority: data['priority'] ?? 'Medium',
      isCompleted: data['isCompleted'] ?? false,
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Work',
      dueDate: map['dueDate'] is Timestamp 
          ? (map['dueDate'] as Timestamp).toDate() 
          : (map['dueDate'] is String ? DateTime.tryParse(map['dueDate']) ?? DateTime.now() : DateTime.now()),
      priority: map['priority'] ?? 'Medium',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : (map['createdAt'] is String ? DateTime.tryParse(map['createdAt']) ?? DateTime.now() : DateTime.now()),
    );
  }
}
