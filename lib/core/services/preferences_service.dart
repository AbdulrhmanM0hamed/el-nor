import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static PreferencesService? _instance;
  late SharedPreferences _prefs;
  
  // Keys
  static const String _hasSeenWaitingDialogKeyPrefix = 'has_seen_waiting_dialog_';
  
  PreferencesService._();
  
  static Future<PreferencesService> getInstance() async {
    if (_instance == null) {
      _instance = PreferencesService._();
      await _instance!._init();
    }
    return _instance!;
  }
  
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Waiting Dialog Methods
  Future<bool> hasUserSeenWaitingDialog(String userId) async {
    return _prefs.getBool('$_hasSeenWaitingDialogKeyPrefix$userId') ?? false;
  }
  
  Future<void> markWaitingDialogAsSeen(String userId) async {
    await _prefs.setBool('$_hasSeenWaitingDialogKeyPrefix$userId', true);
  }
  
  // Add other preference methods here as needed
} 