import mongoose, { Document, Schema } from 'mongoose';

export interface ISale extends Document {
  businessId: mongoose.Types.ObjectId;
  conversationId: mongoose.Types.ObjectId;
  customerPhone: string;
  customerName?: string;
  stripeSessionId?: string;
  stripePaymentIntentId?: string;
  amount: number;
  currency: string;
  status: string;
  products: Array<{
    productId: mongoose.Types.ObjectId;
    name: string;
    price: number;
    quantity: number;
  }>;
  
  createdAt: Date;
  updatedAt: Date;
}

const SaleSchema = new Schema<ISale>({
  businessId: { type: Schema.Types.ObjectId, ref: 'Business', required: true },
  conversationId: { type: Schema.Types.ObjectId, ref: 'Conversation', required: true },
  customerPhone: { type: String, required: true },
  customerName: String,
  stripeSessionId: String,
  stripePaymentIntentId: String,
  amount: { type: Number, required: true },
  currency: { type: String, default: 'USD' },
  status: { type: String, default: 'pending', enum: ['pending', 'completed', 'failed', 'refunded'] },
  products: [{
    productId: { type: Schema.Types.ObjectId, ref: 'Product' },
    name: { type: String, required: true },
    price: { type: Number, required: true },
    quantity: { type: Number, required: true }
  }]
}, {
  timestamps: true
});

// Índices
SaleSchema.index({ businessId: 1 });
SaleSchema.index({ businessId: 1, status: 1 });
SaleSchema.index({ conversationId: 1 });

export const Sale = mongoose.model<ISale>('Sale', SaleSchema);
