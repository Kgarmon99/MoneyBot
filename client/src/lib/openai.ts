import {
  ChatCompletionRequest,
  ChatCompletionResponse,
  FinancialAdviceRequest
} from '../../shared/schema';

// Interface definitions for API interactions
export interface Message {
  role: "system" | "user" | "assistant";
  content: string;
}

export interface ErrorResponse {
  error: {
    code: string;
    message: string;
    status: number;
    request_id: string;
  };
}

export interface MessagesResponse {
  data: {
    id: number;
    userId: number;
    role: string;
    content: string;
    timestamp: string;
    model: string;
    conversationId: string;
  }[];
  meta: {
    total: number;
    conversation_id?: string;
  };
}

export interface ModelResponse {
  data: {
    id: string;
    name: string;
    description: string;
  }[];
}

export interface FinancialAdviceResponse {
  advice: string;
  topic?: string;
  conversation_id: string;
  model: string;
}

// Base URL for API endpoints
const API_BASE_URL = '/api';

// Helper function for making API requests
const apiRequest = async <T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> => {
  const defaultHeaders = {
    'Content-Type': 'application/json',
  };

  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...options,
    headers: {
      ...defaultHeaders,
      ...options.headers,
    },
  });

  const data = await response.json();

  if (!response.ok) {
    throw data;
  }

  return data;
};

// API functions for OpenAI interactions

/**
 * Send a chat completion request to the API
 */
export const sendChatCompletion = async (
  request: ChatCompletionRequest
): Promise<ChatCompletionResponse> => {
  return apiRequest<ChatCompletionResponse>('/chat/completions', {
    method: 'POST',
    body: JSON.stringify(request),
  });
};

/**
 * Get available AI models
 */
export const getModels = async (): Promise<ModelResponse> => {
  return apiRequest<ModelResponse>('/models');
};

/**
 * Get message history, optionally filtered by conversation ID
 */
export const getMessages = async (conversationId?: string): Promise<MessagesResponse> => {
  const endpoint = conversationId
    ? `/messages?conversation_id=${conversationId}`
    : '/messages';
  
  return apiRequest<MessagesResponse>(endpoint);
};

/**
 * Get all conversations
 */
export const getConversations = async () => {
  return apiRequest<{ data: any[], meta: { total: number } }>('/conversations');
};

/**
 * Create a new conversation
 */
export const createConversation = async (title: string) => {
  return apiRequest<{ data: any }>('/conversations', {
    method: 'POST',
    body: JSON.stringify({ title }),
  });
};

/**
 * Delete a conversation
 */
export const deleteConversation = async (id: number) => {
  return apiRequest<void>(`/conversations/${id}`, {
    method: 'DELETE',
  });
};

/**
 * Get personalized financial advice
 */
export const getFinancialAdvice = async (
  request: FinancialAdviceRequest
): Promise<FinancialAdviceResponse> => {
  return apiRequest<FinancialAdviceResponse>('/financial-advice', {
    method: 'POST',
    body: JSON.stringify(request),
  });
};