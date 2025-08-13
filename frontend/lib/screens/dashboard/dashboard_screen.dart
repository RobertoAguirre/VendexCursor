import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../config/theme.dart';
import 'onboarding/onboarding_screen.dart';
import 'widgets/stats_card.dart';
import 'widgets/quick_actions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
  }

  Future<void> _loadBusinessData() async {
    final businessProvider = context.read<BusinessProvider>();
    await businessProvider.loadBusinessInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Text(authProvider.business?.name ?? 'Dashboard');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navegar a configuración
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: Consumer<BusinessProvider>(
        builder: (context, businessProvider, child) {
          if (businessProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Verificar si necesita onboarding
          if (_needsOnboarding(businessProvider)) {
            return const OnboardingScreen();
          }

          return _buildDashboard(businessProvider);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Conversaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Ventas',
          ),
        ],
      ),
    );
  }

  bool _needsOnboarding(BusinessProvider businessProvider) {
    final business = businessProvider.business;
    if (business == null) return true;

    // Verificar si tiene configuración básica
    return business.whatsappNumber == null ||
           business.stripeSecretKey == null ||
           business.assistantPersonality == null;
  }

  Widget _buildDashboard(BusinessProvider businessProvider) {
    final business = businessProvider.business;
    final stats = businessProvider.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bienvenida
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.smart_toy,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Hola! Tu asistente está activo',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Listo para vender y atender clientes',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Estadísticas
          Text(
            'Resumen del Negocio',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              StatsCard(
                title: 'Productos',
                value: '${stats?.products ?? 0}',
                icon: Icons.inventory,
                color: AppTheme.primaryColor,
              ),
              StatsCard(
                title: 'Conversaciones',
                value: '${stats?.conversations ?? 0}',
                icon: Icons.chat,
                color: AppTheme.secondaryColor,
              ),
              StatsCard(
                title: 'Ventas',
                value: '${stats?.sales ?? 0}',
                icon: Icons.shopping_cart,
                color: AppTheme.accentColor,
              ),
              StatsCard(
                title: 'Ingresos',
                value: '\$${(stats?.totalRevenue ?? 0).toStringAsFixed(0)}',
                icon: Icons.attach_money,
                color: AppTheme.successColor,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Acciones rápidas
          Text(
            'Acciones Rápidas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          QuickActions(
            onAddProduct: () {
              // TODO: Navegar a agregar producto
            },
            onViewConversations: () {
              // TODO: Navegar a conversaciones
            },
            onViewSales: () {
              // TODO: Navegar a ventas
            },
            onConfigureAssistant: () {
              // TODO: Navegar a configuración del asistente
            },
          ),
          const SizedBox(height: 24),

          // Estado del asistente
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.successColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Estado del Asistente',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStatusItem('WhatsApp', business?.whatsappNumber != null),
                  _buildStatusItem('Pagos Stripe', business?.stripeSecretKey != null),
                  _buildStatusItem('Personalidad IA', business?.assistantPersonality != null),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, bool isConfigured) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isConfigured ? Icons.check_circle : Icons.circle_outlined,
            color: isConfigured ? AppTheme.successColor : AppTheme.textLight,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isConfigured ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
} 