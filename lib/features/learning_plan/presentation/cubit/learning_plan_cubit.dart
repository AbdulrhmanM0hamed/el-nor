import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/learning_plan_repository.dart';

part 'learning_plan_state.dart';

class LearningPlanCubit extends Cubit<LearningPlanState> {
  final LearningPlanRepository _repo;
  final bool _isAdmin;

  LearningPlanCubit({required LearningPlanRepository repository, required bool isAdmin})
      : _repo = repository,
        _isAdmin = isAdmin,
        super(LearningPlanInitial());

  bool get isAdmin => _isAdmin;

  Future<void> fetchPlan() async {
    emit(LearningPlanLoading());
    final url = await _repo.getPlanUrl();
    if (url == null) {
      emit(LearningPlanEmpty());
    } else {
      emit(LearningPlanLoaded(url));
    }
  }

  Future<void> uploadPlan(File pdf) async {
    if (!_isAdmin) return;
    emit(LearningPlanUploading());
    try {
      await _repo.uploadPlan(pdf);
      emit(LearningPlanUploadSuccess());
      await fetchPlan();
    } catch (e) {
      emit(LearningPlanError(e.toString()));
    }
  }

  Future<void> deletePlan() async {
    if (!_isAdmin) return;
    emit(LearningPlanUploading());
    try {
      await _repo.deletePlan();
      emit(LearningPlanEmpty());
    } catch (e) {
      emit(LearningPlanError(e.toString()));
    }
  }
}
