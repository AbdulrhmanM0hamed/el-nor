import 'package:equatable/equatable.dart';
import '../../data/models/prayer_times_model.dart';

abstract class PrayerTimesState extends Equatable {
  const PrayerTimesState();

  @override
  List<Object?> get props => [];
}

class PrayerTimesInitial extends PrayerTimesState {}

class PrayerTimesLoading extends PrayerTimesState {}

class PrayerTimesLoaded extends PrayerTimesState {
  final PrayerTimesResponse prayerTimes;

  const PrayerTimesLoaded(this.prayerTimes);

  @override
  List<Object?> get props => [prayerTimes];
}

class PrayerTimesError extends PrayerTimesState {
  final String message;

  const PrayerTimesError(this.message);

  @override
  List<Object?> get props => [message];
} 