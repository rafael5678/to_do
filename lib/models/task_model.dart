class Task {
  final String? id;
  final String title;
  final String? description;
  final DateTime date;
  final String category;
  final bool isCompleted;
  final String time;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.date,
    required this.category,
    this.isCompleted = false,
    required this.time,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      category: json['category'],
      isCompleted: json['is_completed'] ?? false,
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
      'is_completed': isCompleted,
      'time': time,
    };
  }
}
