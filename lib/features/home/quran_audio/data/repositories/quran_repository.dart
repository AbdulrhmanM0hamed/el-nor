import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../models/quran_reciter_model.dart';

class QuranRepository {
  final Dio _dio;
  static const String _baseUrl = 'https://api3.islamhouse.com/v3/paV29H2gm56kvLPy/main';

  QuranRepository() : _dio = Dio();

  Future<Either<Failure, List<QuranCollection>>> getReciters() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/quran/ar/ar/1/25/json',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final collections = data.map((json) => QuranCollection.fromJson(json)).toList();
        return Right(collections);
      }

      return const Left(ServerFailure('فشل في تحميل بيانات القراء'));
    } catch (e) {
      // تحسين معالجة الأخطاء للتعرف على نوع الخطأ
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            return const Left(NetworkFailure('انتهت مهلة الاتصال، تأكد من اتصالك بالإنترنت'));
          case DioExceptionType.connectionError:
          case DioExceptionType.badCertificate:
          case DioExceptionType.badResponse:
            return const Left(NetworkFailure('حدث خطأ في الاتصال بالخادم'));
          case DioExceptionType.cancel:
            return const Left(NetworkFailure('تم إلغاء الطلب'));
          case DioExceptionType.unknown:
            if (e.error != null && e.error.toString().contains('SocketException')) {
              return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت، يرجى التحقق من اتصالك والمحاولة مرة أخرى'));
            }
            return Left(ServerFailure('حدث خطأ غير متوقع: ${e.message}'));
          default:
            return Left(ServerFailure('حدث خطأ: ${e.message}'));
        }
      }
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }
}