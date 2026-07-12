import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../theme/colors.dart';

class UpdateService {
  static const String repo = 'OscarAcosta17/transcripciones';

  static Future<String> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  static bool _isGreaterVersion(String current, String latest) {
    List<int> currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      int c = i < currentParts.length ? currentParts[i] : 0;
      int l = i < latestParts.length ? latestParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  static Future<void> checkForUpdates(BuildContext context, {bool silent = false}) async {
    try {
      final currentVersion = await getCurrentVersion();
      final response = await http.get(Uri.parse('https://api.github.com/repos/$repo/releases/latest'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestVersion = data['tag_name'].toString().replaceAll('v', '');
        
        String? downloadUrl;
        if (data['assets'] != null && (data['assets'] as List).isNotEmpty) {
          final assets = data['assets'] as List;
          final apkAsset = assets.firstWhere((a) => a['name'].toString().endsWith('.apk'), orElse: () => null);
          if (apkAsset != null) {
            downloadUrl = apkAsset['browser_download_url'];
          }
        }

        if (_isGreaterVersion(currentVersion, latestVersion) && downloadUrl != null) {
          if (context.mounted) {
            _showUpdateDialog(context, latestVersion, currentVersion, downloadUrl);
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
          const SnackBar(content: Text('Error al comprobar actualizaciones.'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  static void _showUpdateDialog(BuildContext context, String latest, String current, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DownloadDialog(latestVersion: latest, currentVersion: current, downloadUrl: url),
    );
  }
}

class _DownloadDialog extends StatefulWidget {
  final String latestVersion;
  final String currentVersion;
  final String downloadUrl;

  const _DownloadDialog({
    required this.latestVersion,
    required this.currentVersion,
    required this.downloadUrl,
  });

  @override
  State<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<_DownloadDialog> {
  bool isDownloading = false;
  double progress = 0.0;
  String statusText = '';

  Future<void> _startDownload() async {
    setState(() {
      isDownloading = true;
      statusText = 'Iniciando descarga...';
    });

    try {
      final request = http.Request('GET', Uri.parse(widget.downloadUrl));
      final response = await http.Client().send(request);

      final contentLength = response.contentLength ?? 0;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/update_v${widget.latestVersion}.apk');
      final sink = file.openWrite();

      int bytesDownloaded = 0;

      response.stream.listen(
        (List<int> newBytes) {
          sink.add(newBytes);
          bytesDownloaded += newBytes.length;
          if (contentLength > 0) {
            setState(() {
              progress = bytesDownloaded / contentLength;
              statusText = 'Descargando: ${(progress * 100).toStringAsFixed(1)}%';
            });
          }
        },
        onDone: () async {
          await sink.close();
          setState(() {
            statusText = 'Instalando...';
          });
          
          if (mounted) {
            Navigator.pop(context);
          }
          
          final result = await OpenFilex.open(file.path);
          if (result.type != ResultType.done) {
            debugPrint('Error abriendo archivo: ${result.message}');
          }
        },
        onError: (e) async {
          await sink.close();
          if (mounted) {
            setState(() {
              statusText = 'Error en la descarga';
              isDownloading = false;
            });
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          statusText = 'Error de conexión';
          isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Actualización Disponible', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Nueva versión ${widget.latestVersion} está disponible.\\nTienes la versión ${widget.currentVersion}.',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          if (isDownloading) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress > 0 ? progress : null,
                backgroundColor: Colors.white12,
                color: AppColors.primary,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              statusText,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ]
        ],
      ),
      actions: [
        if (!isDownloading)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
        if (!isDownloading)
          TextButton(
            onPressed: _startDownload,
            child: const Text('Descargar e Instalar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
