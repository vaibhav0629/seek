import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? dateFromFirestore(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

Timestamp? dateToFirestore(DateTime? date) =>
    date == null ? null : Timestamp.fromDate(date);

T enumFromName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}

List<String> stringList(Object? value) =>
    value is Iterable ? value.map((e) => e.toString()).toList() : <String>[];
