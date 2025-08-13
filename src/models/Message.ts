import mongoose, { Document, Schema } from 'mongoose';

export interface IMessage extends Document {
  conversationId: mongoose.Types.ObjectId;
  content: string;
  senderType: 'customer' | 'assistant';
  messageType: 'text' | 'image' | 'payment_link';
  metadata: Record<string, any>;
  
  createdAt: Date;
}

const MessageSchema = new Schema<IMessage>({
  conversationId: { type: Schema.Types.ObjectId, ref: 'Conversation', required: true },
  content: { type: String, required: true },
  senderType: { type: String, required: true, enum: ['customer', 'assistant'] },
  messageType: { type: String, default: 'text', enum: ['text', 'image', 'payment_link'] },
  metadata: { type: Schema.Types.Mixed, default: {} }
}, {
  timestamps: { createdAt: true, updatedAt: false }
});

// Índices
MessageSchema.index({ conversationId: 1 });
MessageSchema.index({ conversationId: 1, createdAt: 1 });

export const Message = mongoose.model<IMessage>('Message', MessageSchema);
