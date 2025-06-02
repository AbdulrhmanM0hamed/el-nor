import 'package:equatable/equatable.dart';

class QuranBookmark extends Equatable {
  final int pageNumber;
  final String title;
  final DateTime timestamp;

  const QuranBookmark({
    required this.pageNumber,
    required this.title,
    required this.timestamp,
  });

  factory QuranBookmark.fromJson(Map<String, dynamic> json) {
    return QuranBookmark(
      pageNumber: json['pageNumber'] as int,
      title: json['title'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'title': title,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object> get props => [pageNumber, title, timestamp];
}
