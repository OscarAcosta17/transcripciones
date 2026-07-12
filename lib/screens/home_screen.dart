import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../widgets/mesh_background.dart';
import '../services/transcription_service.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? audioFilePath;
  String? audioFileName;
  bool isTranscribing = false;
  String? transcriptionResult;

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav'],
    );

    if (result != null) {
      setState(() {
        audioFilePath = result.files.single.path;
        audioFileName = result.files.single.name;
        transcriptionResult = null;
      });
    }
  }

  Future<void> _handleTranscribe() async {
    if (audioFilePath == null) return;

    setState(() {
      isTranscribing = true;
    });

    try {
      final text = await TranscriptionService.transcribeAudio(audioFilePath!);
      setState(() {
        transcriptionResult = text;
      });

      await StorageService.saveTranscription({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'filename': audioFileName,
        'date': DateTime.now().toIso8601String(),
        'text': text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transcripción guardada en el historial')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      setState(() {
        isTranscribing = false;
      });
    }
  }

  Future<void> _handleExport() async {
    if (transcriptionResult == null) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text('Exportar como', style: TextStyle(color: AppColors.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Texto plano (.txt)', style: TextStyle(color: AppColors.text)),
              leading: const Icon(LucideIcons.fileText, color: AppColors.primary),
              onTap: () {
                Navigator.pop(ctx);
                _exportFile('txt');
              },
            ),
            ListTile(
              title: const Text('Markdown (.md)', style: TextStyle(color: AppColors.text)),
              leading: const Icon(LucideIcons.fileCode, color: AppColors.primary),
              onTap: () {
                Navigator.pop(ctx);
                _exportFile('md');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportFile(String extension) async {
    try {
      final directory = await getTemporaryDirectory();
      final name = audioFileName?.split('.').first ?? 'audio';
      final file = File('${directory.path}/Transcripcion_$name.$extension');
      await file.writeAsString(transcriptionResult!);
      await Share.shareXFiles([XFile(file.path)], text: 'Transcripción generada por Transcriptor Liquid');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al exportar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshBackground(
        child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Transcriptor Liquid',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              GlassCard(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0x1A4361EE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.mic, color: AppColors.primary, size: 40),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Sube tu archivo de audio',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Soporta mp3, m4a, wav y más formatos.',
                      style: TextStyle(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),
                    GlassButton(
                      title: audioFileName ?? 'Seleccionar Audio',
                      icon: const Icon(LucideIcons.fileText, color: AppColors.text, size: 20),
                      baseColor: AppColors.glassBorder,
                      onPressed: _pickAudio,
                    ),
                    if (audioFilePath != null) ...[
                      const SizedBox(height: 15),
                      GlassButton(
                        title: isTranscribing ? 'Transcribiendo...' : 'Iniciar Transcripción',
                        isLoading: isTranscribing,
                        onPressed: _handleTranscribe,
                      ),
                      if (isTranscribing) ...[
                        const SizedBox(height: 15),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: const LinearProgressIndicator(
                            backgroundColor: Colors.white12,
                            color: AppColors.primary,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              if (transcriptionResult != null) ...[
                const SizedBox(height: 20),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Resultado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          transcriptionResult!,
                          style: const TextStyle(color: AppColors.text, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 15),
                      GlassButton(
                        title: 'Exportar Resultados',
                        baseColor: AppColors.success,
                        icon: const Icon(LucideIcons.download, color: AppColors.text, size: 20),
                        onPressed: _handleExport,
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
        ),
      ),
    );
  }
}

