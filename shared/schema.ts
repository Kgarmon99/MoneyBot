import { pgTable, serial, text, timestamp, integer, boolean } from 'drizzle-orm/pg-core';
import { createInsertSchema } from 'drizzle-zod';
import { z } from 'zod';

// Define conversations table
export const conversationsTable = pgTable('conversations', {
  id: serial('id').primaryKey(),
  title: text('title').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull()
});

// Define messages table
export const messagesTable = pgTable('messages', {
  id: serial('id').primaryKey(),
  conversationId: integer('conversation_id').references(() => conversationsTable.id).notNull(),
  role: text('role').notNull(),
  content: text('content').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  model: text('model')
});

// Create insert schemas (omitting auto-generated fields)
export const insertConversationSchema = createInsertSchema(conversationsTable).omit({ 
  id: true,
  createdAt: true,
  updatedAt: true
});

export const insertMessageSchema = createInsertSchema(messagesTable).omit({ 
  id: true,
  createdAt: true
});

// Export types for use in application
export type Conversation = typeof conversationsTable.$inferSelect;
export type InsertConversation = z.infer<typeof insertConversationSchema>;

export type Message = typeof messagesTable.$inferSelect;
export type InsertMessage = z.infer<typeof insertMessageSchema>;

// AI Model Schema
export const aiModelSchema = z.object({
  id: z.string(),
  name: z.string(),
  description: z.string()
});

export type AIModel = z.infer<typeof aiModelSchema>;

// Chat Completion Request Schema
export const chatCompletionRequestSchema = z.object({
  model: z.string(),
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

// Chat Completion Response Schemas
export const chatCompletionChoiceSchema = z.object({
  message: z.object({
    role: z.string(),
    content: z.string()
  }),
  finish_reason: z.string(),
  index: z.number()
});

export const chatCompletionResponseSchema = z.object({
  id: z.string(),
  object: z.string(),
  created: z.number(),
  model: z.string(),
  choices: z.array(chatCompletionChoiceSchema),
  usage: z.object({
    prompt_tokens: z.number(),
    completion_tokens: z.number(),
    total_tokens: z.number()
  }),
  conversation_id: z.string()
});

export type ChatCompletionResponse = z.infer<typeof chatCompletionResponseSchema>;

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