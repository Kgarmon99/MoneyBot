import { Router } from 'express';
import { z } from 'zod';
import OpenAI from 'openai';
import { MemStorage } from './storage';
import { 
  chatCompletionRequestSchema,
  financialAdviceRequestSchema,
} from '../shared/schema';

// Initialize storage
const storage = new MemStorage();

// Initialize OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

// Create router
export const router = Router();

// Define request validation middleware
const validateRequest = (schema: z.ZodTypeAny) => {
  return (req: any, res: any, next: any) => {
    try {
      req.validatedBody = schema.parse(req.body);
      next();
    } catch (error) {
      if (error instanceof z.ZodError) {
        res.status(400).json({
          error: {
            code: 'validation_error',
            message: 'Invalid request data',
            details: error.errors,
            status: 400,
            request_id: req.id
          }
        });
      } else {
        next(error);
      }
    }
  };
};

// Health check endpoint
router.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Get available models
router.get('/models', async (req, res, next) => {
  try {
    const models = await storage.getModels();
    res.json({
      data: models
    });
  } catch (error) {
    next(error);
  }
});

// Chat completions endpoint
router.post('/chat/completions', validateRequest(chatCompletionRequestSchema), async (req: any, res, next) => {
  try {
    const { messages, model = 'gpt-4o', conversation_id, temperature = 0.7, max_tokens = 500 } = req.validatedBody;
    
    // Call OpenAI API
    const completion = await openai.chat.completions.create({
      model, // the newest OpenAI model is "gpt-4o" which was released May 13, 2024
      messages,
      temperature,
      max_tokens
    });
    
    // Store the conversation and messages if conversation_id is provided
    if (conversation_id) {
      // Check if conversation exists
      const conversationId = parseInt(conversation_id);
      let conversation = await storage.getConversation(conversationId);
      
      if (!conversation) {
        // Create a new conversation
        conversation = await storage.createConversation({
          title: messages[0]?.content?.substring(0, 50) + '...' || 'New Conversation'
        });
      }
      
      // Store user message
      const userMessage = messages[messages.length - 1];
      await storage.createMessage({
        conversationId: conversation.id,
        role: userMessage.role,
        content: userMessage.content,
        model
      });
      
      // Store assistant response
      if (completion.choices && completion.choices.length > 0) {
        await storage.createMessage({
          conversationId: conversation.id,
          role: completion.choices[0].message.role,
          content: completion.choices[0].message.content || '',
          model
        });
      }
    }
    
    // Format response
    const response = {
      id: completion.id,
      object: completion.object,
      created: completion.created,
      model: completion.model,
      choices: completion.choices,
      usage: completion.usage,
      conversation_id: conversation_id
    };
    
    res.json(response);
  } catch (error: any) {
    console.error('Error calling OpenAI:', error);
    
    res.status(error.status || 500).json({
      error: {
        code: error.code || 'server_error',
        message: error.message || 'An unexpected error occurred',
        status: error.status || 500,
        request_id: req.id
      }
    });
  }
});

// Financial advice endpoint
router.post('/financial-advice', validateRequest(financialAdviceRequestSchema), async (req: any, res, next) => {
  try {
    const { topic, question, userContext } = req.validatedBody;
    
    // Create a specialized prompt for financial advice
    let systemPrompt = 'You are MoneyBot, an AI financial advisor specializing in providing clear, accurate, and helpful financial advice. ';
    
    if (topic) {
      systemPrompt += `The user is asking about ${topic}. `;
    }
    
    if (userContext) {
      systemPrompt += 'Here is some context about the user: ';
      
      if (userContext.experience) {
        systemPrompt += `Experience level: ${userContext.experience}. `;
      }
      
      if (userContext.age) {
        systemPrompt += `Age: ${userContext.age}. `;
      }
      
      if (userContext.hasDebt !== undefined) {
        systemPrompt += `Has debt: ${userContext.hasDebt ? 'Yes' : 'No'}. `;
      }
      
      if (userContext.hasInvestments !== undefined) {
        systemPrompt += `Has investments: ${userContext.hasInvestments ? 'Yes' : 'No'}. `;
      }
      
      if (userContext.monthlyIncome) {
        systemPrompt += `Monthly income: $${userContext.monthlyIncome}. `;
      }
    }
    
    systemPrompt += '\nProvide detailed but easy-to-understand advice. When appropriate, include examples and concrete next steps. Always be ethical and factual in financial matters.';
    
    // Call OpenAI API
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o', // the newest OpenAI model is "gpt-4o" which was released May 13, 2024
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: question }
      ],
      temperature: 0.5, // More factual responses for financial advice
    });
    
    const advice = completion.choices[0].message.content;
    
    // Create a conversation to store this interaction
    const conversation = await storage.createConversation({
      title: question.substring(0, 50) + '...' || 'Financial Advice'
    });
    
    // Store user question
    await storage.createMessage({
      conversationId: conversation.id,
      role: 'user',
      content: question,
      model: 'gpt-4o'
    });
    
    // Store assistant response
    await storage.createMessage({
      conversationId: conversation.id,
      role: 'assistant',
      content: advice || '',
      model: 'gpt-4o'
    });
    
    res.json({
      advice,
      topic,
      conversation_id: conversation.id.toString(),
      model: 'gpt-4o'
    });
  } catch (error: any) {
    console.error('Error generating financial advice:', error);
    
    res.status(error.status || 500).json({
      error: {
        code: error.code || 'server_error',
        message: error.message || 'An unexpected error occurred',
        status: error.status || 500,
        request_id: req.id
      }
    });
  }
});