import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/business_provider.dart';
import '../../../config/theme.dart';

class AssistantStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const AssistantStep({
    Key? key,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  @override
  State<AssistantStep> createState() => _AssistantStepState();
}

class _AssistantStepState extends State<AssistantStep> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  String _selectedPersonality = 'friendly';
  final _customPersonalityController = TextEditingController();
  bool _isLoading = false;

  final Map<String, String> _personalities = {
    'friendly': 'Amigable y cercano',
    'professional': 'Profesional y formal',
    'enthusiastic': 'Entusiasta y motivador',
    'expert': 'Experto y técnico',
    'custom': 'Personalizado',
  };

  @override
  void dispose() {
    _apiKeyController.dispose();
    _customPersonalityController.dispose();
    super.dispose();
  }

  Future<void> _configureAssistant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final businessProvider = context.read<BusinessProvider>();
      
      // Configurar API key de Anthropic
      final apiKeySuccess = await businessProvider.configureAnthropic(
        _apiKeyController.text.trim(),
      );

      if (!apiKeySuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error configurando API key de Anthropic'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Configurar personalidad
      String personality = _selectedPersonality == 'custom' 
          ? _customPersonalityController.text.trim()
          : _personalities[_selectedPersonality]!;

      final personalitySuccess = await businessProvider.configureAssistantPersonality(
        personality,
      );

      if (personalitySuccess) {
        widget.onNext();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error configurando personalidad del asistente'),
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
              'Configurar Asistente IA',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configura la personalidad de tu asistente y conecta con Claude AI.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Anthropic API Key
            TextFormField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Anthropic API Key *',
                hintText: 'sk-ant-...',
                prefixIcon: Icon(Icons.key),
                border: OutlineInputBorder(),
                helperText: 'Obtén tu API key en console.anthropic.com',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'API Key requerida';
                }
                if (!value.startsWith('sk-ant-')) {
                  return 'La API Key debe comenzar con sk-ant-';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Personalidad del asistente
            const Text(
              'Personalidad del Asistente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Opciones de personalidad
            ...(_personalities.entries.map((entry) => RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _selectedPersonality,
              onChanged: (value) {
                setState(() {
                  _selectedPersonality = value!;
                });
              },
            )).toList()),

            // Campo personalizado
            if (_selectedPersonality == 'custom') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _customPersonalityController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Describe la personalidad personalizada',
                  hintText: 'Ej: Eres un vendedor experto en tecnología que ayuda a clientes a encontrar la mejor solución...',
                  border: OutlineInputBorder(),
                  helperText: 'Describe cómo quieres que se comporte tu asistente',
                ),
                validator: (value) {
                  if (_selectedPersonality == 'custom' && (value == null || value.trim().isEmpty)) {
                    return 'Descripción de personalidad requerida';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 24),

            // Información sobre Claude
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.orange.shade600),
                      const SizedBox(width: 8),
                      const Text(
                        '¿Qué es Claude AI?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Claude es una IA avanzada de Anthropic que entiende el contexto '
                    'y puede mantener conversaciones naturales. Tu asistente usará '
                    'Claude para responder a tus clientes de forma inteligente.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Consejos
            ExpansionTile(
              title: const Text('Consejos para una buena personalidad'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '• Sé específico sobre el tono (amigable, profesional, etc.)',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Incluye información sobre tu negocio y productos',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Define cómo debe manejar objeciones y preguntas',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Especifica si debe ser proactivo en las ventas',
                        style: TextStyle(fontSize: 14),
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
                    onPressed: _isLoading ? null : _configureAssistant,
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
