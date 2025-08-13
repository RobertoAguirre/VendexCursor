import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/business_provider.dart';
import '../../../config/theme.dart';
import 'steps/whatsapp_step.dart';
import 'steps/stripe_step.dart';
import 'steps/assistant_step.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
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
    // TODO: Marcar onboarding como completado
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Configuración Inicial'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Paso ${_currentStep + 1} de $_totalSteps',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${((_currentStep + 1) / _totalSteps * 100).round()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _totalSteps,
                  backgroundColor: AppTheme.textLight.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                // Paso 1: WhatsApp
                WhatsAppStep(
                  onNext: _nextStep,
                ),
                
                // Paso 2: Stripe
                StripeStep(
                  onNext: _nextStep,
                  onPrevious: _previousStep,
                ),
                
                // Paso 3: Asistente IA
                AssistantStep(
                  onComplete: _completeOnboarding,
                  onPrevious: _previousStep,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 