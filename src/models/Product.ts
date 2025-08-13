import mongoose, { Document, Schema } from 'mongoose';

export interface IProduct extends Document {
  businessId: mongoose.Types.ObjectId;
  name: string;
  price: number;
  stock: number;
  description?: string;
  imageUrl?: string;
  active: boolean;
  
  // Campos flexibles para diferentes tipos de negocio
  metadata?: Record<string, any>;
  
  createdAt: Date;
  updatedAt: Date;
}

const ProductSchema = new Schema<IProduct>({
  businessId: { type: Schema.Types.ObjectId, ref: 'Business', required: true },
  name: { type: String, required: true },
  price: { type: Number, required: true },
  stock: { type: Number, default: 0 },
  description: String,
  imageUrl: String,
  active: { type: Boolean, default: true },
  
  // Campos flexibles para diferentes tipos de negocio
  metadata: { type: Schema.Types.Mixed, default: {} }
}, {
  timestamps: true
});

// Índices
ProductSchema.index({ businessId: 1 });
ProductSchema.index({ businessId: 1, active: 1 });

export const Product = mongoose.model<IProduct>('Product', ProductSchema);
