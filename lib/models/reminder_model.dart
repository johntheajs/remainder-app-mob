class Reminder {
  int? id;
  int userId; // Foreign key referencing User
  String title;
  String date;
  String time;
  String description;

  Reminder({
    this.id,
    required this.userId,
    required this.title,
    required this.date,
    required this.time,
    required this.description,
  });

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      date: map['date'],
      time: map['time'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'date': date,
      'time': time,
      'description': description,
    };
  }
}

