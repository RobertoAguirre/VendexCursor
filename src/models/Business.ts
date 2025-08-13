import mongoose, { Document, Schema } from 'mongoose';

export interface IBusiness extends Document {
  name: string;
  email: string;
  passwordHash: string;
  phone?: string;
  businessType?: string;
  description?: string;
  
  // Stripe Configuration
  stripeSecretKey?: string;
  stripeWebhookSecret?: string;
  stripePublishableKey?: string;
  
  // UltraMsg Configuration
  whatsappNumber?: string;
  ultramsgInstanceId?: string;
  ultramsgToken?: string;
  
  // AI Configuration
  anthropicApiKey?: string;
  assistantPersonality?: string;
  
  // Status
  isActive: boolean;
  onboardingCompleted: boolean;
  
  createdAt: Date;
  updatedAt: Date;
}

const BusinessSchema = new Schema<IBusiness>({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  passwordHash: { type: String, required: true },
  phone: String,
  businessType: String,
  description: String,
  
  // Stripe Configuration
  stripeSecretKey: String,
  stripeWebhookSecret: String,
  stripePublishableKey: String,
  
  // UltraMsg Configuration
  whatsappNumber: String,
  ultramsgInstanceId: String,
  ultramsgToken: String,
  
  // AI Configuration
  anthropicApiKey: String,
  assistantPersonality: String,
  
  // Status
  isActive: { type: Boolean, default: true },
  onboardingCompleted: { type: Boolean, default: false }
}, {
  timestamps: true
});

// Índices
BusinessSchema.index({ email: 1 });
BusinessSchema.index({ isActive: 1 });

export const Business = mongoose.model<IBusiness>('Business', BusinessSchema);
