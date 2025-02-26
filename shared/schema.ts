import { z } from 'zod';

/* Database Schema Interfaces */
export interface Conversation {
  id: number;
  title: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Message {
  id: number;
  conversationId: number;
  role: string;
  content: string;
  model?: string;
  createdAt: Date;
}

export interface InsertConversation {
  title: string;
}

export interface InsertMessage {
  conversationId: number;
  role: string;
  content: string;
  model?: string;
}

/* API Schemas */
export const aiModelSchema = z.object({
  id: z.string(),
  name: z.string(),
  description: z.string()
});

export type AIModel = z.infer<typeof aiModelSchema>;

export const chatCompletionRequestSchema = z.object({
  model: z.string().optional().default('gpt-4o'),
  messages: z.array(
    z.object({
      role: z.enum(['system', 'user', 'assistant']),
      content: z.string()
    })
  ),
  temperature: z.number().optional(),
  max_tokens: z.number().optional(),
  conversation_id: z.string().optional()
});

export type ChatCompletionRequest = z.infer<typeof chatCompletionRequestSchema>;

// Financial Topics Schema
export const financialTopicSchema = z.enum([
  'budgeting',
  'investing',
  'retirement',
  'debt',
  'saving',
  'taxes',
  'insurance',
  'real_estate',
  'credit',
  'general'
]);

export type FinancialTopic = z.infer<typeof financialTopicSchema>;

// Financial Advice Request Schema
export const financialAdviceRequestSchema = z.object({
  topic: financialTopicSchema.optional(),
  question: z.string(),
  userContext: z.object({
    experience: z.enum(['beginner', 'intermediate', 'advanced']).optional(),
    age: z.number().optional(),
    hasDebt: z.boolean().optional(),
    hasInvestments: z.boolean().optional(),
    monthlyIncome: z.number().optional()
  }).optional()
});

export type FinancialAdviceRequest = z.infer<typeof financialAdviceRequestSchema>;