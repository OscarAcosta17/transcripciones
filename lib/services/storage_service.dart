import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StorageService {
  static const String _historyKey = 'transcription_history';
  static const String _apiKeyKey = 'gemini_api_key';

  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey) ?? dotenv.env['GEMINI_API_KEY'];
  }

  static Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, key);
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString(_historyKey);
    if (historyString == null) return [];

    List<dynamic> jsonList = jsonDecode(historyString);
    return jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> saveTranscription(Map<String, dynamic> item) async {
    final history = await getHistory();
    history.insert(0, item); // add at the beginning
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  static Future<void> deleteTranscription(String id) async {
    final history = await getHistory();
    history.removeWhere((item) => item['id'] == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  static Future<bool> canTranscribeToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    final lastDate = prefs.getString('last_transcription_date');
    
    if (lastDate != today) {
      // New day, reset count
      await prefs.setString('last_transcription_date', today);
      await prefs.setInt('transcription_count', 0);
      return true;
    }
    
    final count = prefs.getInt('transcription_count') ?? 0;
    return count < 3;
  }

  static Future<void> incrementTranscriptionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('transcription_count') ?? 0;
    await prefs.setInt('transcription_count', count + 1);
  }
}
