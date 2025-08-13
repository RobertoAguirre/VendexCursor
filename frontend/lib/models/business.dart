class Business {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? businessType;
  final String? description;
  
  // WhatsApp y UltraMsg
  final String? whatsappNumber;
  final String? ultramsgInstanceId;
  final String? ultramsgToken;
  
  // Stripe
  final String? stripeSecretKey;
  final String? stripeWebhookSecret;
  final String? stripePublishableKey;
  
  // Anthropic
  final String? anthropicApiKey;
  final String? assistantPersonality;
  
  // Status
  final bool isActive;
  final bool onboardingCompleted;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  Business({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.businessType,
    this.description,
    this.whatsappNumber,
    this.ultramsgInstanceId,
    this.ultramsgToken,
    this.stripeSecretKey,
    this.stripeWebhookSecret,
    this.stripePublishableKey,
    this.anthropicApiKey,
    this.assistantPersonality,
    this.isActive = true,
    this.onboardingCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      businessType: json['business_type'],
      description: json['description'],
      whatsappNumber: json['whatsapp_number'],
      ultramsgInstanceId: json['ultramsg_instance_id'],
      ultramsgToken: json['ultramsg_token'],
      stripeSecretKey: json['stripe_secret_key'],
      stripeWebhookSecret: json['stripe_webhook_secret'],
      stripePublishableKey: json['stripe_publishable_key'],
      anthropicApiKey: json['anthropic_api_key'],
      assistantPersonality: json['assistant_personality'],
      isActive: json['is_active'] ?? true,
      onboardingCompleted: json['onboarding_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'business_type': businessType,
      'description': description,
      'whatsapp_number': whatsappNumber,
      'ultramsg_instance_id': ultramsgInstanceId,
      'ultramsg_token': ultramsgToken,
      'stripe_secret_key': stripeSecretKey,
      'stripe_webhook_secret': stripeWebhookSecret,
      'stripe_publishable_key': stripePublishableKey,
      'anthropic_api_key': anthropicApiKey,
      'assistant_personality': assistantPersonality,
      'is_active': isActive,
      'onboarding_completed': onboardingCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Business copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? businessType,
    String? description,
    String? whatsappNumber,
    String? ultramsgInstanceId,
    String? ultramsgToken,
    String? stripeSecretKey,
    String? stripeWebhookSecret,
    String? stripePublishableKey,
    String? anthropicApiKey,
    String? assistantPersonality,
    bool? isActive,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      businessType: businessType ?? this.businessType,
      description: description ?? this.description,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      ultramsgInstanceId: ultramsgInstanceId ?? this.ultramsgInstanceId,
      ultramsgToken: ultramsgToken ?? this.ultramsgToken,
      stripeSecretKey: stripeSecretKey ?? this.stripeSecretKey,
      stripeWebhookSecret: stripeWebhookSecret ?? this.stripeWebhookSecret,
      stripePublishableKey: stripePublishableKey ?? this.stripePublishableKey,
      anthropicApiKey: anthropicApiKey ?? this.anthropicApiKey,
      assistantPersonality: assistantPersonality ?? this.assistantPersonality,
      isActive: isActive ?? this.isActive,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Business(id: $id, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Business && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 