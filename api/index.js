require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const morgan = require('morgan');
const OpenAI = require('openai');

// Initialize express app
const app = express();
const port = process.env.PORT || 3000;

// Setup middleware
app.use(cors());
app.use(bodyParser.json());
app.use(morgan('dev'));

// Initialize OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

// Create a memory store for conversations
const conversations = new Map();

// Helper function to get or create conversation
const getOrCreateConversation = (conversationId) => {
  if (!conversations.has(conversationId)) {
    conversations.set(conversationId, [
      { role: 'system', content: process.env.DEFAULT_SYSTEM_PROMPT }
    ]);
  }
  return conversations.get(conversationId);
};

// Middleware to check API key
const apiKeyMiddleware = (req, res, next) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      error: {
        code: 'authentication_error',
        message: 'Missing or invalid API key',
        status: 401,
        request_id: req.id
      }
    });
  }
  
  // This is a mock API key check. In a real app, you'd validate 
  // against a database of valid keys.
  const apiKey = authHeader.split(' ')[1];
  if (apiKey === 'test_invalid_key') {
    return res.status(401).json({
      error: {
        code: 'authentication_error',
        message: 'API key is invalid or expired',
        status: 401,
        request_id: req.id
      }
    });
  }
  
  next();
};

// Add request ID middleware
app.use((req, res, next) => {
  req.id = 'req_' + Math.random().toString(36).substr(2, 9);
  next();
});

// API routes
app.post('/api/v1/chat/completions', apiKeyMiddleware, async (req, res) => {
  try {
    const { model, messages, temperature = 0.7, max_tokens = 500, conversation_id } = req.body;
    
    if (!model || !messages || !Array.isArray(messages)) {
      return res.status(400).json({
        error: {
          code: 'invalid_request_error',
          message: 'Missing required parameters: model or messages',
          status: 400,
          request_id: req.id
        }
      });
    }
    
    // Use a default conversation ID if not provided
    const conversationId = conversation_id || 'conv_' + Math.random().toString(36).substr(2, 9);
    
    // Get existing conversation or create new one
    const conversationHistory = getOrCreateConversation(conversationId);
    
    // Add new user messages to the conversation
    const userMessages = messages.filter(msg => msg.role !== 'system');
    conversationHistory.push(...userMessages);
    
    // Ensure conversation doesn't grow too large (token limit considerations)
    if (conversationHistory.length > 10) {
      // Keep system message and last 9 messages
      conversationHistory.splice(1, conversationHistory.length - 10);
    }
    
    // Call OpenAI API
    const completion = await openai.chat.completions.create({
      model: model || process.env.DEFAULT_MODEL,
      messages: conversationHistory,
      temperature,
      max_tokens
    });
    
    // Add assistant's response to conversation history
    if (completion.choices && completion.choices.length > 0) {
      conversationHistory.push(completion.choices[0].message);
    }
    
    // Format response
    const response = {
      id: completion.id,
      object: completion.object,
      created: completion.created,
      model: completion.model,
      choices: completion.choices,
      usage: completion.usage,
      conversation_id: conversationId
    };
    
    res.json(response);
  } catch (error) {
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

// Get message history
app.get('/api/v1/messages', apiKeyMiddleware, (req, res) => {
  const { conversation_id } = req.query;
  
  if (!conversation_id) {
    // Return list of all conversation IDs
    return res.json({
      data: Array.from(conversations.keys()).map(id => ({
        id,
        message_count: conversations.get(id).length - 1 // Subtract system message
      })),
      meta: {
        total: conversations.size
      }
    });
  }
  
  // Get specific conversation
  const conversation = conversations.get(conversation_id);
  
  if (!conversation) {
    return res.status(404).json({
      error: {
        code: 'not_found_error',
        message: 'Conversation not found',
        status: 404,
        request_id: req.id
      }
    });
  }
  
  // Format messages for response (skip system message)
  const messages = conversation
    .filter(msg => msg.role !== 'system')
    .map((msg, index) => ({
      id: index,
      userId: 101, // Mock user ID
      role: msg.role,
      content: msg.content,
      timestamp: new Date().toISOString(), // In a real app, you'd store actual timestamps
      model: process.env.DEFAULT_MODEL,
      conversationId: conversation_id
    }));
  
  res.json({
    data: messages,
    meta: {
      total: messages.length,
      conversation_id
    }
  });
});

// Get available models
app.get('/api/v1/models', apiKeyMiddleware, (req, res) => {
  // This is a mock response with a limited set of models
  res.json({
    data: [
      {
        id: "gpt-4o",
        name: "GPT-4o",
        description: "Most advanced model, great for a wide range of tasks with stronger reasoning"
      },
      {
        id: "gpt-4-turbo",
        name: "GPT-4 Turbo",
        description: "Enhanced version of GPT-4 with improved performance"
      },
      {
        id: "gpt-3.5-turbo",
        name: "GPT-3.5 Turbo",
        description: "Fast and efficient model for most everyday tasks"
      }
    ]
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Static documentation page (for testing)
app.use(express.static('public'));

// Start server
app.listen(port, () => {
  console.log(`MoneyBot API server listening on port ${port}`);
});

module.exports = app; // For testing