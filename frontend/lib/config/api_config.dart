class ApiConfig {
  // URL base de la API - Configuración dinámica para desarrollo/producción
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );
  
  // URLs de desarrollo y producción
  static const String developmentUrl = 'http://localhost:3000/api';
  static const String productionUrl = 'https://vendex-claude-backend.onrender.com/api';
  
  // Endpoints de autenticación
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  
  // Endpoints de negocio
  static const String business = '/business';
  static const String assistantPersonality = '/business/assistant-personality';
  static const String whatsapp = '/business/whatsapp';
  static const String stripe = '/business/stripe';
  
  // Endpoints de productos
  static const String products = '/products';
  static const String importProducts = '/products/import';
  
  // Endpoints de conversaciones
  static const String conversations = '/conversations';
  static const String conversationStats = '/conversations/stats/summary';
  static const String searchConversations = '/conversations/search';
  
  // Endpoints de WhatsApp
  static const String whatsappWebhook = '/whatsapp/webhook';
  static const String sendWhatsApp = '/whatsapp/send';
  static const String whatsappConversations = '/whatsapp/conversations';
  
  // Endpoints de Stripe
  static const String createPaymentLink = '/stripe/create-payment-link';
  static const String stripeWebhook = '/stripe/webhook';
  static const String sales = '/stripe/sales';
  static const String salesStats = '/stripe/sales/stats';
  
  // Headers por defecto
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Headers con autorización
  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
  
  // Timeout de requests
  static const Duration timeout = Duration(seconds: 30);
  
  // Configuración de retry
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Configuración de desarrollo
  static const bool isDevelopment = bool.fromEnvironment('dart.vm.product') == false;
  
  // URLs de desarrollo y producción
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:3000',
  );
  static const String frontendUrl = String.fromEnvironment(
    'FRONTEND_URL',
    defaultValue: 'http://localhost:3000',
  );
  
  // Método para obtener la URL base según el entorno
  static String get apiBaseUrl {
    if (isDevelopment) {
      return developmentUrl;
    }
    return productionUrl;
  }
} 