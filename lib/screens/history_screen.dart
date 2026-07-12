import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/mesh_background.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await StorageService.getHistory();
    setState(() {
      history = data;
    });
  }

  Future<void> _deleteItem(String id) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Eliminar', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro de que quieres eliminar esta transcripción?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await StorageService.deleteTranscription(id);
              _loadHistory();
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  Future<void> _shareItem(Map<String, dynamic> item) async {
    try {
      final directory = await getTemporaryDirectory();
      final name = item['filename']?.split('.').first ?? 'audio';
      final file = File('${directory.path}/Transcripcion_$name.txt');
      await file.writeAsString(item['text']);
      await Share.shareXFiles([XFile(file.path)], text: 'Transcripción');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al compartir')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshBackground(
        child: SafeArea(
          child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Historial',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ),
            Expanded(
              child: history.isEmpty
                  ? const Center(
                      child: Text(
                        'No tienes transcripciones aún.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: GlassCard(
                            padding: 15,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['filename'] ?? 'Sin nombre',
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      DateTime.parse(item['date']).toString().split(' ')[0],
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  item['text'],
                                  style: const TextStyle(color: AppColors.text, height: 1.4),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _shareItem(item),
                                      icon: const Icon(LucideIcons.share2, color: AppColors.text, size: 18),
                                      label: const Text('Compartir', style: TextStyle(color: AppColors.text)),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _deleteItem(item['id']),
                                      icon: const Icon(LucideIcons.trash2, color: AppColors.danger, size: 18),
                                      label: const Text('Eliminar', style: TextStyle(color: AppColors.danger)),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
