// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class ApiEndpoints {
//   // المتغيرات الأساسية مع قيم افتراضية
//   static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
//   static String get api_key => dotenv.env['API_KEY'] ?? '';

//   //================ المصادقة وإدارة الحساب ================//
//   static String get login => '$baseUrl/login';
//   static String get register => '$baseUrl/register?api_key=$api_key';
//   static String get logout => '$baseUrl/logout';
//   static String get forgotPassword =>
//       '$baseUrl/forgot-password?api_key=$api_key';
//   static String get resetPassword => '$baseUrl/reset-password?api_key=$api_key';
//   static String get refreshToken => '$baseUrl/auth/refresh';

//   //================ الملف الشخصي ================//
//   static String get profile => '$baseUrl/user/profile?api_key=$api_key';
//   static String get updateProfile => '$baseUrl/profile';
//   static String get changePassword =>
//       '$baseUrl/user/change-password?api_key=$api_key';
//   static String get userStatistics =>
//       '$baseUrl/user/statistics?api_key=$api_key';

//   //================ الطلبات والخدمات ================//
//   static String services = '$baseUrl/services?api_key=$api_key';
//   static String statistics = '$baseUrl/statistics?api_key=$api_key';
//   static String discounts = '$baseUrl/discounts?api_key=$api_key';

//   //================ إدارة الطلبات ================//
//   static String myOrders = '$baseUrl/my-list-orders?api_key=$api_key';
//   static String allOrders = '$baseUrl/list-orders';
//   static String addMyOrder = '$baseUrl/add-my-orders?api_key=$api_key';
//   static String myReservations = '$baseUrl/my-reservations';

//   static String deleteOrder(int id) =>
//       '$baseUrl/my-list-orders/$id?api_key=$api_key';
//   static String orderDetails(int orderId) => '$baseUrl/orders/$orderId/details';

//   //================ العروض والتفاعلات ================//
//   static String acceptOffer(int orderId, int offerId) =>
//       '$baseUrl/orders/$orderId/accept-offer/$offerId?api_key=$api_key';
//   static String cancelOffer(int orderId, int offerId) =>
//       '$baseUrl/orders/$orderId/cancel-offer/$offerId?api_key=$api_key';

//   //================ المتاجر والصالونات ================//
//   static String premiumShops = '$baseUrl/shops/premium?api_key=$api_key';
//   static String shopProfile(int shopId) =>
//       '$baseUrl/shops/$shopId/?api_key=$api_key';
//   static String shopFullDetails(int shopId) =>
//       '$baseUrl/shops/$shopId/full-details?api_key=$api_key';

//   //================ التقييمات والمفضلة ================//
//   static String addShopRating(int shopId) =>
//       '$baseUrl/shops/$shopId/rate?api_key=$api_key';
//   static String deleteShopRating(int shopId) =>
//       '$baseUrl/shops/$shopId/rate?api_key=$api_key';
//   static String myFavoriteShops =
//       '$baseUrl/my-favorite-shops/?api_key=$api_key';
//   static String addToFavorites(int shopId) =>
//       '$baseUrl/shops/$shopId/like?api_key=$api_key';
//   static String removeFromFavorites(int shopId) =>
//       '$baseUrl/shops/$shopId/like?api_key=$api_key';

//   //================ الحجوزات ================//
//   static String bookService(int shopId) =>
//       '$baseUrl/shops/$shopId/book-service?api_key=$api_key';
//   static String bookDiscount(int shopId) =>
//       '$baseUrl/shops/$shopId/book-discount?api_key=$api_key';
//   static String cancelAppointment(int serviceId) =>
//       '$baseUrl/appointments/$serviceId/cancel?api_key=$api_key';

//   //================ البحث والتصفية ================//
//   static String searchServices(String query) =>
//       '$baseUrl/services/search?query=$query&api_key=$api_key';
//   static String searchShops = '$baseUrl/shops/search';
//   static String searchShopsByType({String? type, String? search}) =>
//       '$baseUrl/shops/search?type=$type${search != null ? '&search=$search' : ''}&api_key=$api_key';
      

//   //================ الإشعارات ================//
//   static String notifications = '$baseUrl/notifications?api_key=$api_key';
//   static String notificationsDelete =
//       '$baseUrl/notifications/all?api_key=$api_key';
//   static String getMarkNotificationReadPath(String id) =>
//       '$baseUrl/notifications/$id/read?api_key=$api_key';

//   //================ دالة تصفية المتاجر ================//
//   static String filterShops({String? type, String? search, int page = 1}) {
//     final params = <String, String>{
//       'api_key': api_key,
//       'page': page.toString(),
//     };

//     if (type != null && type != 'all') {
//       params['type'] = type;
//     }

//     if (search != null && search.isNotEmpty) {
//       params['search'] = search;
//     }

//     final queryString =
//         params.entries.map((e) => '${e.key}=${e.value}').join('&');
//     return '$baseUrl/filter-shops?$queryString';
//   }
// }
