import 'package:task_count/data/models/custom_date.dart';

class Task {
  final int id;
  final bool isChecked;
  final CustomDate date;
  final String note;

  Task({
    required this.id,
    required this.isChecked,
    required this.note,
    required this.date,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      isChecked: json['isChecked'] == 1,
      note: (json['note'] ?? "") as String,
      date: CustomDate(date: DateTime.parse(json['date'] as String)),
    );
  }
}
