import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'storage_service.dart';
import 'package:path/path.dart' as p;

class TranscriptionService {
  static Future<String> transcribeAudio(String filePath) async {
    final apiKey = await StorageService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API Key no configurada. Ve a Ajustes.');
    }

    final model = GenerativeModel(
      model: 'gemini-3.5-flash',
      apiKey: apiKey,
    );

    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final extension = p.extension(filePath).replaceAll('.', '');
    
    // Mapear extensión a mime type
    String mimeType = 'audio/mp3';
    if (extension == 'wav') mimeType = 'audio/wav';
    if (extension == 'm4a') mimeType = 'audio/m4a';
    if (extension == 'ogg') mimeType = 'audio/ogg';

    final prompt = TextPart('Por favor, transcribe todo lo que se dice en este audio de manera precisa y detallada.');
    final audioData = DataPart(mimeType, bytes);

    try {
      final response = await model.generateContent([
        Content.multi([prompt, audioData])
      ]);
      return response.text ?? 'No se pudo generar la transcripción.';
    } catch (e) {
      throw Exception('Error al transcribir con Gemini: $e');
    }
  }
}
