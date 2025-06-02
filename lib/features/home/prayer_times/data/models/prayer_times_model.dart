import 'package:equatable/equatable.dart';

class PrayerTimesResponse extends Equatable {
  final String region;
  final String country;
  final PrayerTimes prayerTimes;
  final DateInfo date;
  final Meta meta;

  const PrayerTimesResponse({
    required this.region,
    required this.country,
    required this.prayerTimes,
    required this.date,
    required this.meta,
  });

  factory PrayerTimesResponse.fromJson(Map<String, dynamic> json) {
    return PrayerTimesResponse(
      region: json['region'] ?? '',
      country: json['country'] ?? '',
      prayerTimes: PrayerTimes.fromJson(json['prayer_times'] ?? {}),
      date: DateInfo.fromJson(json['date'] ?? {}),
      meta: Meta.fromJson(json['meta'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [region, country, prayerTimes, date, meta];
}

class PrayerTimes extends Equatable {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  const PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      fajr: json['Fajr'] ?? '',
      sunrise: json['Sunrise'] ?? '',
      dhuhr: json['Dhuhr'] ?? '',
      asr: json['Asr'] ?? '',
      maghrib: json['Maghrib'] ?? '',
      isha: json['Isha'] ?? '',
    );
  }

  @override
  List<Object?> get props => [fajr, sunrise, dhuhr, asr, maghrib, isha];
}

class DateInfo extends Equatable {
  final String dateEn;
  final HijriDate dateHijri;

  const DateInfo({
    required this.dateEn,
    required this.dateHijri,
  });

  factory DateInfo.fromJson(Map<String, dynamic> json) {
    return DateInfo(
      dateEn: json['date_en'] ?? '',
      dateHijri: HijriDate.fromJson(json['date_hijri'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [dateEn, dateHijri];
}

class HijriDate extends Equatable {
  final String date;
  final String format;
  final String day;
  final Weekday weekday;
  final Month month;
  final String year;

  const HijriDate({
    required this.date,
    required this.format,
    required this.day,
    required this.weekday,
    required this.month,
    required this.year,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      date: json['date'] ?? '',
      format: json['format'] ?? '',
      day: json['day'] ?? '',
      weekday: Weekday.fromJson(json['weekday'] ?? {}),
      month: Month.fromJson(json['month'] ?? {}),
      year: json['year'] ?? '',
    );
  }

  @override
  List<Object?> get props => [date, format, day, weekday, month, year];
}

class Weekday extends Equatable {
  final String en;
  final String ar;

  const Weekday({
    required this.en,
    required this.ar,
  });

  factory Weekday.fromJson(Map<String, dynamic> json) {
    return Weekday(
      en: json['en'] ?? '',
      ar: json['ar'] ?? '',
    );
  }

  @override
  List<Object?> get props => [en, ar];
}

class Month extends Equatable {
  final int number;
  final String en;
  final String ar;
  final int days;

  const Month({
    required this.number,
    required this.en,
    required this.ar,
    required this.days,
  });

  factory Month.fromJson(Map<String, dynamic> json) {
    return Month(
      number: json['number'] ?? 0,
      en: json['en'] ?? '',
      ar: json['ar'] ?? '',
      days: json['days'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [number, en, ar, days];
}

class Meta extends Equatable {
  final String timezone;

  const Meta({
    required this.timezone,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      timezone: json['timezone'] ?? '',
    );
  }

  @override
  List<Object?> get props => [timezone];
} 