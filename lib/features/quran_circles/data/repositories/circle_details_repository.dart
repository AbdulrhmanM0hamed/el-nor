import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../datasources/circle_details_remote_datasource.dart';
import '../models/student_record.dart';

abstract class CircleDetailsRepository {
  Future<Either<Failure, Map<String, dynamic>>> getCurrentUserPermissions(String circleTeacherId);
  Future<Either<Failure, void>> updateStudentEvaluation({
    required String circleId,
    required String studentId,
    required EvaluationRecord evaluation,
  });
  Future<Either<Failure, void>> updateStudentAttendance({
    required String circleId,
    required String studentId,
    required AttendanceRecord attendance,
  });
}

class CircleDetailsRepositoryImpl implements CircleDetailsRepository {
  final CircleDetailsRemoteDataSource remoteDataSource;

  CircleDetailsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCurrentUserPermissions(String circleTeacherId) async {
    try {
      final result = await remoteDataSource.getCurrentUserPermissions(circleTeacherId);
      return Right(result);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStudentEvaluation({
    required String circleId,
    required String studentId,
    required EvaluationRecord evaluation,
  }) async {
    try {
    
      
      await remoteDataSource.updateStudentEvaluation(
        circleId: circleId,
        studentId: studentId,
        evaluation: evaluation,
      );
      
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStudentAttendance({
    required String circleId,
    required String studentId,
    required AttendanceRecord attendance,
  }) async {
    try {
     
      
      await remoteDataSource.updateStudentAttendance(
        circleId: circleId,
        studentId: studentId,
        attendance: attendance,
      );
      
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
} 