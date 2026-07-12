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
  String version = '1.0.1';
  bool isChecking = false;

  @override
  void initState() {
    super.initState();
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
