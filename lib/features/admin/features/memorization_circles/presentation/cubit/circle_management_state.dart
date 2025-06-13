
// حالة قائمة الحلقات المحمولة
import 'package:beat_elslam/features/admin/data/models/memorization_circle_model.dart';
import 'package:beat_elslam/features/admin/features/user_management/presentation/cubit/admin_state.dart';

class AdminCirclesLoaded extends AdminState {
  final List<MemorizationCircleModel> circles;

  const AdminCirclesLoaded(this.circles);

  @override
  List<Object> get props => [circles];
}

// State for loaded circle students


// State for created circle
// حالة إنشاء حلقة جديدة
class AdminCircleCreated extends AdminState {
  final MemorizationCircleModel circle;

  const AdminCircleCreated(this.circle);

  @override
  List<Object?> get props => [circle];
}

// State for updated circle
// حالة تحديث حلقة موجودة
class AdminCircleUpdated extends AdminState {
  final MemorizationCircleModel circle;

  const AdminCircleUpdated(this.circle);

  @override
  List<Object?> get props => [circle];
}

// State for deleted circle
// حالة حذف حلقة
class AdminCircleDeleted extends AdminState {
  final String circleId;

  const AdminCircleDeleted(this.circleId);

  @override
  List<Object> get props => [circleId];
}