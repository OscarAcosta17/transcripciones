import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../widgets/mesh_background.dart';
import '../services/storage_service.dart';
import '../services/update_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool isChecking = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final key = await StorageService.getApiKey();
    if (key != null) {
      _apiKeyController.text = key;
    }
  }

  Future<void> _saveApiKey() async {
    await StorageService.saveApiKey(_apiKeyController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key guardada exitosamente')),
      );
    }
  }

  Future<void> _checkUpdates() async {
    setState(() {
      isChecking = true;
    });
    await UpdateService.checkForUpdates(context);
    setState(() {
      isChecking = false;
    });
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
                  'Configuración',
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.key, color: AppColors.primary),
                        SizedBox(width: 10),
                        Text(
                          'OpenAI API Key',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Para utilizar el servicio de transcripción de Whisper, necesitas una clave API de OpenAI.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: true,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        hintText: 'sk-...',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    GlassButton(
                      title: 'Guardar Clave API',
                      onPressed: _saveApiKey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.refreshCw, color: AppColors.primary),
                        SizedBox(width: 10),
                        Text(
                          'Actualizaciones',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Versión actual: ${UpdateService.currentVersion}',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 15),
                    GlassButton(
                      title: isChecking ? 'Comprobando...' : 'Buscar Actualizaciones',
                      isLoading: isChecking,
                      baseColor: AppColors.glassBorder,
                      onPressed: _checkUpdates,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.info, color: AppColors.primary),
                        SizedBox(width: 10),
                        Text(
                          'Acerca de',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Transcriptor Liquid - Creado para OscarAcosta17.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        ),
      ),
    );
  }
}
