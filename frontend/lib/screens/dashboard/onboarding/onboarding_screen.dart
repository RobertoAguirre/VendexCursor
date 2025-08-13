import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/business_provider.dart';
import '../../../config/theme.dart';
import 'steps/whatsapp_step.dart';
import 'steps/stripe_step.dart';
import 'steps/assistant_step.dart';
import 'steps/products_step.dart';
import 'steps/complete_step.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'WhatsApp',
      'description': 'Conecta tu WhatsApp',
      'icon': Icons.whatsapp,
    },
    {
      'title': 'Pagos',
      'description': 'Configura Stripe',
      'icon': Icons.payment,
    },
    {
      'title': 'Asistente',
      'description': 'Personaliza tu IA',
      'icon': Icons.smart_toy,
    },
    {
      'title': 'Productos',
      'description': 'Agrega tus productos',
      'icon': Icons.inventory,
    },
    {
      'title': '¡Listo!',
      'description': 'Comienza a vender',
      'icon': Icons.rocket_launch,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    // Marcar onboarding como completado
    context.read<BusinessProvider>().markOnboardingComplete();
    
    // Navegar al dashboard
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración Inicial'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Step Indicators
                Row(
                  children: _steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    final isActive = index == _currentStep;
                    final isCompleted = index < _currentStep;

                    return Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Colors.green
                                  : isActive
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCompleted ? Icons.check : step['icon'],
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            step['title'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Progress Bar
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _steps.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Paso ${_currentStep + 1} de ${_steps.length}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1: WhatsApp
                WhatsAppStep(
                  onNext: _nextStep,
                  onPrevious: _previousStep,
                ),

                // Step 2: Stripe
                StripeStep(
                  onNext: _nextStep,
                  onPrevious: _previousStep,
                ),

                // Step 3: Assistant
                AssistantStep(
                  onNext: _nextStep,
                  onPrevious: _previousStep,
                ),

                // Step 4: Products
                ProductsStep(
                  onNext: _nextStep,
                  onPrevious: _previousStep,
                ),

                // Step 5: Complete
                CompleteStep(
                  onComplete: _completeOnboarding,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 