import 'dart:convert';

class ExpenseModel {
  String title;
  String value;
  String date;
  bool isOpen;

  ExpenseModel({
    required this.title,
    required this.value,
    required this.date,
    this.isOpen = true,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'value': value,
      'date': date,
      'isOpen': isOpen,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      title: map['title'] as String,
      value: map['value'] as String,
      date: map['date'] as String,
      isOpen: map['isOpen'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ExpenseModel.fromJson(String source) =>
      ExpenseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
