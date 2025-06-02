import 'package:equatable/equatable.dart';

class MasbahaState extends Equatable {
  final int counter;
  final List<int> savedCounts;

  const MasbahaState({
    this.counter = 0,
    this.savedCounts = const [],
  });

  MasbahaState copyWith({
    int? counter,
    List<int>? savedCounts,
  }) {
    return MasbahaState(
      counter: counter ?? this.counter,
      savedCounts: savedCounts ?? this.savedCounts,
    );
  }

  @override
  List<Object> get props => [counter, savedCounts];
} 