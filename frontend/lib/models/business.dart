class Business {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? businessType;
  final String? description;
  final String? whatsappNumber;
  final String? assistantPersonality;
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
    this.assistantPersonality,
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
      assistantPersonality: json['assistant_personality'],
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
      'assistant_personality': assistantPersonality,
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
    String? assistantPersonality,
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
      assistantPersonality: assistantPersonality ?? this.assistantPersonality,
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