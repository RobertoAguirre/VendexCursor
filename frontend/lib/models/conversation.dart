class Conversation {
  final int id;
  final int businessId;
  final String customerPhone;
  final String? customerName;
  final String status;
  final int totalMessages;
  final DateTime lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.businessId,
    required this.customerPhone,
    this.customerName,
    required this.status,
    required this.totalMessages,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      businessId: json['business_id'],
      customerPhone: json['customer_phone'],
      customerName: json['customer_name'],
      status: json['status'],
      totalMessages: json['total_messages'],
      lastMessageAt: DateTime.parse(json['last_message_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'customer_phone': customerPhone,
      'customer_name': customerName,
      'status': status,
      'total_messages': totalMessages,
      'last_message_at': lastMessageAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Conversation copyWith({
    int? id,
    int? businessId,
    String? customerPhone,
    String? customerName,
    String? status,
    int? totalMessages,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      customerPhone: customerPhone ?? this.customerPhone,
      customerName: customerName ?? this.customerName,
      status: status ?? this.status,
      totalMessages: totalMessages ?? this.totalMessages,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == 'active';
  bool get isClosed => status == 'closed';

  String get formattedLastMessageAt {
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  @override
  String toString() {
    return 'Conversation(id: $id, customerPhone: $customerPhone, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Message {
  final int id;
  final int conversationId;
  final String content;
  final String senderType; // 'customer' o 'assistant'
  final String messageType; // 'text', 'image', 'payment_link'
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.senderType,
    required this.messageType,
    this.metadata,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversation_id'],
      content: json['content'],
      senderType: json['sender_type'],
      messageType: json['message_type'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'content': content,
      'sender_type': senderType,
      'message_type': messageType,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isFromCustomer => senderType == 'customer';
  bool get isFromAssistant => senderType == 'assistant';
  bool get isText => messageType == 'text';
  bool get isImage => messageType == 'image';
  bool get isPaymentLink => messageType == 'payment_link';

  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'Message(id: $id, content: $content, senderType: $senderType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
