import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class UpdateService {
  static const String repo = 'OscarAcosta17/transcripciones';
  static const String currentVersion = '1.0.2'; // Should match pubspec.yaml

  static Future<void> checkForUpdates(BuildContext context, {bool silent = false}) async {
    try {
      final response = await http.get(Uri.parse('https://api.github.com/repos/$repo/releases/latest'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestVersion = data['tag_name'].toString().replaceAll('v', '');
        
        String releaseUrl = data['html_url'];
        if (data['assets'] != null && (data['assets'] as List).isNotEmpty) {
          final assets = data['assets'] as List;
          final apkAsset = assets.firstWhere((a) => a['name'].toString().endsWith('.apk'), orElse: () => null);
          if (apkAsset != null) {
            releaseUrl = apkAsset['browser_download_url'];
          }
        }

        if (latestVersion != currentVersion) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF1E293B),
                title: const Text('Actualización Disponible', style: TextStyle(color: Colors.white)),
                content: Text(
                  'Nueva versión $latestVersion está disponible. Tienes la versión $currentVersion.',
                  style: const TextStyle(color: Colors.white70)
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final url = Uri.parse(releaseUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: const Text('Descargar', style: TextStyle(color: Color(0xFF4361EE))),
                  ),
                ],
              ),
            );
          }
        } else {
          if (!silent && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tienes la última versión de la aplicación.')),
            );
          }
        }
      }
    } catch (e) {
      if (!silent && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al comprobar actualizaciones.')),
        );
      }
    }
  }
}
