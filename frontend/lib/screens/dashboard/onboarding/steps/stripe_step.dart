import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/business_provider.dart';
import '../../../config/theme.dart';

class StripeStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const StripeStep({
    Key? key,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  @override
  State<StripeStep> createState() => _StripeStepState();
}

class _StripeStepState extends State<StripeStep> {
  final _formKey = GlobalKey<FormState>();
  final _secretKeyController = TextEditingController();
  final _publishableKeyController = TextEditingController();
  final _webhookSecretController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _secretKeyController.dispose();
    _publishableKeyController.dispose();
    _webhookSecretController.dispose();
    super.dispose();
  }

  Future<void> _configureStripe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await context.read<BusinessProvider>().configureStripe(
        secretKey: _secretKeyController.text.trim(),
        publishableKey: _publishableKeyController.text.trim(),
        webhookSecret: _webhookSecretController.text.trim().isEmpty 
            ? null 
            : _webhookSecretController.text.trim(),
      );

      if (success) {
        widget.onNext();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error configurando Stripe. Verifica tus credenciales.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Configurar Pagos',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Conecta tu cuenta de Stripe para procesar pagos de forma segura.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Stripe Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      const Text(
                        '¿Qué es Stripe?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Stripe es la plataforma de pagos más confiable del mundo. '
                    'Procesa tarjetas de crédito, débito y otros métodos de pago '
                    'de forma segura y automática.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Secret Key Field
            TextFormField(
              controller: _secretKeyController,
              decoration: const InputDecoration(
                labelText: 'Stripe Secret Key *',
                hintText: 'sk_test_... o sk_live_...',
                prefixIcon: Icon(Icons.vpn_key),
                border: OutlineInputBorder(),
                helperText: 'Encuentra esto en Developers → API Keys',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La Secret Key es requerida';
                }
                if (!value.startsWith('sk_')) {
                  return 'La Secret Key debe comenzar con sk_';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Publishable Key Field
            TextFormField(
              controller: _publishableKeyController,
              decoration: const InputDecoration(
                labelText: 'Stripe Publishable Key *',
                hintText: 'pk_test_... o pk_live_...',
                prefixIcon: Icon(Icons.public),
                border: OutlineInputBorder(),
                helperText: 'Encuentra esto en Developers → API Keys',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La Publishable Key es requerida';
                }
                if (!value.startsWith('pk_')) {
                  return 'La Publishable Key debe comenzar con pk_';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Webhook Secret Field (Optional)
            TextFormField(
              controller: _webhookSecretController,
              decoration: const InputDecoration(
                labelText: 'Webhook Secret (Opcional)',
                hintText: 'whsec_...',
                prefixIcon: Icon(Icons.webhook),
                border: OutlineInputBorder(),
                helperText: 'Para notificaciones automáticas de pagos',
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty && !value.startsWith('whsec_')) {
                  return 'El Webhook Secret debe comenzar con whsec_';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Help Section
            ExpansionTile(
              title: const Text('¿Cómo obtener mis credenciales?'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. Ve a stripe.com y crea una cuenta',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '2. En el Dashboard, ve a Developers → API Keys',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '3. Copia tu "Secret key" (comienza con sk_test_ o sk_live_)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '4. Copia tu "Publishable key" (comienza con pk_test_ o pk_live_)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '5. Para webhooks: Developers → Webhooks → Add endpoint',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Abrir Stripe en el navegador
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Abrir Stripe Dashboard'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onPrevious,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Anterior'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _configureStripe,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Siguiente'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
