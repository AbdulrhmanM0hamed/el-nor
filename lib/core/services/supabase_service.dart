import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  static void resetInstance() {
    _instance = null;
  }

  SupabaseClient get supabaseClient => Supabase.instance.client;
} 