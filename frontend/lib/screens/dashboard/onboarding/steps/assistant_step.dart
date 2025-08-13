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
  final _personalityController = TextEditingController();
  bool _isLoading = false;
  String _selectedTemplate = '';

  final List<Map<String, dynamic>> _templates = [
    {
      'id': 'friendly',
      'name': 'Amigable y Cercano',
      'description': 'Un asistente cálido que construye relaciones personales',
      'template': 'Eres un asistente de ventas amigable y cercano. Te comunicas de manera cálida y personal, como un amigo que quiere ayudar. Usas emojis ocasionalmente y mantienes un tono conversacional. Tu objetivo es hacer que el cliente se sienta cómodo y confíe en ti.',
    },
    {
      'id': 'professional',
      'name': 'Profesional y Formal',
      'description': 'Un asistente serio y confiable para negocios formales',
      'template': 'Eres un asistente de ventas profesional y formal. Te comunicas de manera seria y confiable, manteniendo un tono respetuoso y empresarial. Eres directo, eficiente y te enfocas en proporcionar información clara y precisa.',
    },
    {
      'id': 'enthusiastic',
      'name': 'Entusiasta y Energético',
      'description': 'Un asistente motivador que genera emoción',
      'template': 'Eres un asistente de ventas entusiasta y energético. Te comunicas con pasión y emoción, generando entusiasmo en el cliente. Usas lenguaje motivador y te enfocas en los beneficios emocionales de los productos.',
    },
    {
      'id': 'expert',
      'name': 'Experto Técnico',
      'description': 'Un asistente especializado con conocimiento profundo',
      'template': 'Eres un asistente de ventas experto y técnico. Tienes conocimiento profundo de los productos y te comunicas con autoridad. Proporcionas información detallada y técnica, ayudando al cliente a tomar decisiones informadas.',
    },
    {
      'id': 'custom',
      'name': 'Personalizado',
      'description': 'Define tu propia personalidad',
      'template': '',
    },
  ];

  @override
  void dispose() {
    _personalityController.dispose();
    super.dispose();
  }

  void _selectTemplate(String templateId) {
    setState(() {
      _selectedTemplate = templateId;
      final template = _templates.firstWhere((t) => t['id'] == templateId);
      _personalityController.text = template['template'] ?? '';
    });
  }

  Future<void> _configureAssistant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await context.read<BusinessProvider>().configureAssistantPersonality(
        _personalityController.text.trim(),
      );

      if (success) {
        widget.onNext();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error configurando el asistente. Intenta de nuevo.'),
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
              'Personalizar Asistente IA',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Define la personalidad de tu asistente de ventas para que coincida con tu marca.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Templates Section
            const Text(
              'Plantillas de Personalidad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Template Cards
            ...(_templates.map((template) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: RadioListTile<String>(
                title: Text(
                  template['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(template['description']),
                value: template['id'],
                groupValue: _selectedTemplate,
                onChanged: (value) => _selectTemplate(value!),
                activeColor: Theme.of(context).primaryColor,
              ),
            )).toList()),

            const SizedBox(height: 24),

            // Custom Personality Field
            const Text(
              'Personalidad del Asistente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Describe cómo quieres que se comporte tu asistente:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _personalityController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Ejemplo: Eres un asistente amigable que ayuda a los clientes a encontrar los mejores productos...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La personalidad del asistente es requerida';
                }
                if (value.trim().length < 50) {
                  return 'La descripción debe tener al menos 50 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tips Card
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
                      Icon(Icons.lightbulb, color: Colors.orange.shade600),
                      const SizedBox(width: 8),
                      const Text(
                        'Consejos para una buena personalidad:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('• Define el tono de comunicación (formal, casual, amigable)'),
                  const Text('• Especifica cómo debe tratar a los clientes'),
                  const Text('• Incluye valores de tu marca (confianza, innovación, etc.)'),
                  const Text('• Define el nivel de formalidad y uso de emojis'),
                  const Text('• Especifica si debe ser técnico o simple'),
                ],
              ),
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
