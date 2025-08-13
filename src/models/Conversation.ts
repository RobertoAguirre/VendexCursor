import mongoose, { Document, Schema } from 'mongoose';

export interface IConversation extends Document {
  businessId: mongoose.Types.ObjectId;
  customerPhone: string;
  customerName?: string;
  status: string;
  totalMessages: number;
  lastMessageAt: Date;
  context: Record<string, any>;
  
  createdAt: Date;
  updatedAt: Date;
}

const ConversationSchema = new Schema<IConversation>({
  businessId: { type: Schema.Types.ObjectId, ref: 'Business', required: true },
  customerPhone: { type: String, required: true },
  customerName: String,
  status: { type: String, default: 'active', enum: ['active', 'closed', 'pending'] },
  totalMessages: { type: Number, default: 0 },
  lastMessageAt: { type: Date, default: Date.now },
  context: { type: Schema.Types.Mixed, default: {} }
}, {
  timestamps: true
});

// Índices
ConversationSchema.index({ businessId: 1 });
ConversationSchema.index({ businessId: 1, customerPhone: 1 });
ConversationSchema.index({ businessId: 1, status: 1 });

export const Conversation = mongoose.model<IConversation>('Conversation', ConversationSchema);
