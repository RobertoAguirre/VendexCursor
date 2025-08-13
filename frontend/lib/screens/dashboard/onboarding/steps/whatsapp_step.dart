import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../providers/business_provider.dart';
import '../../../../config/theme.dart';

class WhatsAppStep extends StatefulWidget {
  final VoidCallback onNext;

  const WhatsAppStep({
    super.key,
    required this.onNext,
  });

  @override
  State<WhatsAppStep> createState() => _WhatsAppStepState();
}

class _WhatsAppStepState extends State<WhatsAppStep> {
  final _formKey = GlobalKey<FormState>();
  final _whatsappController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _configureWhatsApp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final businessProvider = context.read<BusinessProvider>();
      final success = await businessProvider.configureWhatsApp(
        _whatsappController.text.trim(),
      );

      if (success && mounted) {
        widget.onNext();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(businessProvider.error ?? 'Error configurando WhatsApp'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openUltraMsgGuide() async {
    const url = 'https://ultramsg.com/docs/';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono y título
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.whatsapp,
                  size: 40,
                  color: Color(0xFF25D366),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Conecta tu WhatsApp',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Text(
              'Tu asistente responderá automáticamente a los mensajes de tus clientes',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Información sobre UltraMsg
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.infoColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Necesitas una cuenta en UltraMsg',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'UltraMsg es un servicio que conecta WhatsApp con aplicaciones. Es necesario para que tu asistente funcione.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _openUltraMsgGuide,
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Ver guía de UltraMsg'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Campo de número de WhatsApp
            TextFormField(
              controller: _whatsappController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Número de WhatsApp *',
                prefixIcon: Icon(Icons.phone),
                hintText: '+1234567890',
                helperText: 'Incluye el código de país (ej: +1 para Estados Unidos)',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Número de WhatsApp requerido';
                }
                if (!value.startsWith('+')) {
                  return 'Debe incluir el código de país (ej: +1)';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Botón siguiente
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _configureWhatsApp,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Configurar WhatsApp'),
              ),
            ),
            const SizedBox(height: 16),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.accentColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.accentColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Consejo',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Una vez configurado, tu asistente responderá automáticamente a todos los mensajes que lleguen a este número de WhatsApp.',
                    style: TextStyle(
                      color: AppTheme.accentColor.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 