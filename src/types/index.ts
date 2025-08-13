export interface Business {
  id: number;
  name: string;
  email: string;
  phone?: string;
  business_type?: string;
  description?: string;
  stripe_secret_key?: string;
  stripe_webhook_secret?: string;
  whatsapp_number?: string;
  assistant_personality?: string;
  created_at: Date;
  updated_at: Date;
}

export interface Product {
  id: number;
  business_id: number;
  name: string;
  price: number;
  stock: number;
  description?: string;
  image_url?: string;
  active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface Conversation {
  id: number;
  business_id: number;
  customer_phone: string;
  status: 'active' | 'closed' | 'pending';
  last_message_at: Date;
  context: any;
  created_at: Date;
  updated_at: Date;
}

export interface Message {
  id: number;
  conversation_id: number;
  content: string;
  sender_type: 'customer' | 'assistant';
  message_type: 'text' | 'image' | 'payment_link';
  metadata: any;
  created_at: Date;
}

export interface Sale {
  id: number;
  business_id: number;
  customer_phone: string;
  amount: number;
  stripe_payment_id?: string;
  products: any[];
  status: 'pending' | 'completed' | 'failed' | 'cancelled';
  created_at: Date;
  updated_at: Date;
}

export interface CreateBusinessRequest {
  name: string;
  email: string;
  password: string;
  phone?: string;
  business_type?: string;
  description?: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface CreateProductRequest {
  name: string;
  price: number;
  stock: number;
  description?: string;
  image_url?: string;
}

export interface WhatsAppMessage {
  instance_id: string;
  token: string;
  phone: string;
  message: string;
  image?: string;
}

export interface ClaudeRequest {
  business_id: number;
  customer_message: string;
  conversation_context: any;
  products: Product[];
} 