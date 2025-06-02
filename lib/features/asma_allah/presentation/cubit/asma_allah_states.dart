import 'package:equatable/equatable.dart';
import '../../models/allah_name_model.dart';

abstract class AsmaAllahState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AsmaAllahInitial extends AsmaAllahState {}

class AsmaAllahLoading extends AsmaAllahState {}

class AsmaAllahLoaded extends AsmaAllahState {
  final List<AllahName> allNames;
  final int? selectedNameIndex;

  AsmaAllahLoaded({
    required this.allNames, 
    this.selectedNameIndex,
  });

  @override
  List<Object?> get props => [allNames, selectedNameIndex];

  AsmaAllahLoaded copyWith({
    List<AllahName>? allNames,
    int? selectedNameIndex,
  }) {
    return AsmaAllahLoaded(
      allNames: allNames ?? this.allNames,
      selectedNameIndex: selectedNameIndex ?? this.selectedNameIndex,
    );
  }
}

class AsmaAllahError extends AsmaAllahState {
  final String errorMessage;

  AsmaAllahError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
} 