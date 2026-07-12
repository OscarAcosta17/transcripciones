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
  String version = '1.0.3';
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
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0x1A4361EE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.mic, color: AppColors.primary, size: 50),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Transcriptor Liquid',
                            style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Versión $version',
                            style: const TextStyle(color: AppColors.primary, fontSize: 14),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Desarrollado con Flutter y Google AI Studio. Diseño inmersivo Liquid Glass para la mejor experiencia de usuario.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                          ),
                          const SizedBox(height: 30),
                          ListTile(
                            leading: const Icon(LucideIcons.fileText, color: AppColors.textMuted),
                            title: const Text('Términos y Condiciones', style: TextStyle(color: AppColors.text)),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(LucideIcons.shield, color: AppColors.textMuted),
                            title: const Text('Política de Privacidad', style: TextStyle(color: AppColors.text)),
                            onTap: () {},
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cerrar', style: TextStyle(color: AppColors.primary)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Icon(LucideIcons.chevronRight, color: AppColors.textMuted),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Información legal, versión y créditos de la aplicación.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
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
