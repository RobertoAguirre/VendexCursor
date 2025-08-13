import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/business_provider.dart';
import '../../../config/theme.dart';

class CompleteStep extends StatefulWidget {
  final VoidCallback onComplete;

  const CompleteStep({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<CompleteStep> createState() => _CompleteStepState();
}

class _CompleteStepState extends State<CompleteStep> {
  bool _isLoading = false;

  Future<void> _markOnboardingComplete() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final businessProvider = context.read<BusinessProvider>();
      final success = await businessProvider.markOnboardingComplete();

      if (success && mounted) {
        widget.onComplete();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(businessProvider.error ?? 'Error completando onboarding'),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green.shade600,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          const Text(
            '¡Configuración Completada!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Subtitle
          const Text(
            'Tu asistente de ventas está listo para comenzar',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Configuration Summary
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green.shade600, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Configuración Verificada',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Configuration Items
                _buildConfigItem(
                  icon: Icons.whatsapp,
                  title: 'WhatsApp + UltraMsg',
                  description: 'Conectado y listo para mensajes',
                  color: Colors.green,
                ),
                const SizedBox(height: 16),

                _buildConfigItem(
                  icon: Icons.payment,
                  title: 'Stripe',
                  description: 'Pagos configurados y seguros',
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),

                _buildConfigItem(
                  icon: Icons.psychology,
                  title: 'Claude AI',
                  description: 'Asistente inteligente activo',
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),

                _buildConfigItem(
                  icon: Icons.shopping_bag,
                  title: 'Productos',
                  description: 'Catálogo configurado',
                  color: Colors.purple,
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // What's Next Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.rocket_launch, color: Colors.blue.shade600, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      '¿Qué sigue?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Next Steps List
                _buildStepItem(
                  icon: Icons.notifications,
                  title: 'Activar Notificaciones',
                  description: 'Recibe alertas de nuevos mensajes',
                  color: Colors.green,
                ),
                const SizedBox(height: 16),

                _buildStepItem(
                  icon: Icons.shopping_cart,
                  title: 'Agregar Más Productos',
                  description: 'Expande tu catálogo desde el dashboard',
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),

                _buildStepItem(
                  icon: Icons.analytics,
                  title: 'Monitorear Ventas',
                  description: 'Revisa conversaciones y ventas en tiempo real',
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),

                _buildStepItem(
                  icon: Icons.settings,
                  title: 'Personalizar Más',
                  description: 'Ajusta la personalidad del asistente según necesites',
                  color: Colors.purple,
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // Features Preview
          const Text(
            'Tu Asistente Puede:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Features Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildFeatureCard(
                icon: Icons.chat_bubble,
                title: 'Responder Mensajes',
                description: 'IA conversacional 24/7',
                color: Colors.blue,
              ),
              _buildFeatureCard(
                icon: Icons.recommend,
                title: 'Recomendar Productos',
                description: 'Sugerencias inteligentes',
                color: Colors.green,
              ),
              _buildFeatureCard(
                icon: Icons.payment,
                title: 'Procesar Pagos',
                description: 'Links de Stripe automáticos',
                color: Colors.orange,
              ),
              _buildFeatureCard(
                icon: Icons.trending_up,
                title: 'Generar Ventas',
                description: 'Conversiones automáticas',
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Complete Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _markOnboardingComplete,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '¡Comenzar a Vender!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Help Text
          const Text(
            '¿Necesitas ayuda? Revisa nuestra documentación o contacta soporte.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.check_circle, color: Colors.green, size: 20),
      ],
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
