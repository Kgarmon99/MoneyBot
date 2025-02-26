import { apiRequest } from "./queryClient";

// API client for MoneyBot API
export interface Message {
  role: "system" | "user" | "assistant";
  content: string;
}

export interface ChatCompletionRequest {
  model: string;
  messages: Message[];
  temperature?: number;
  max_tokens?: number;
  format?: "text" | "json_object";
  conversation_id?: string;
}

export interface ChatCompletionResponse {
  id: string;
  object: string;
  created: number;
  model: string;
  choices: {
    index: number;
    message: Message;
    finish_reason: string;
  }[];
  usage: {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  };
  conversation_id: string;
}

export interface ErrorResponse {
  error: {
    code: string;
    message: string;
    status: number;
    request_id: string;
  };
}

export interface ModelResponse {
  data: {
    id: string;
    name: string;
    description: string;
  }[];
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

export const sendChatCompletion = async (request: ChatCompletionRequest, apiKey: string): Promise<ChatCompletionResponse> => {
  const response = await fetch('/api/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`
    },
    body: JSON.stringify(request)
  });
  
  if (!response.ok) {
    const errorData = await response.json() as ErrorResponse;
    throw new Error(errorData.error.message || 'Failed to send chat completion');
  }
  
  return await response.json() as ChatCompletionResponse;
};

export const getModels = async (apiKey: string): Promise<ModelResponse> => {
  const response = await fetch('/api/v1/models', {
    headers: {
      'Authorization': `Bearer ${apiKey}`
    }
  });
  
  if (!response.ok) {
    const errorData = await response.json() as ErrorResponse;
    throw new Error(errorData.error.message || 'Failed to fetch models');
  }
  
  return await response.json() as ModelResponse;
};

export const getMessages = async (apiKey: string, conversationId?: string): Promise<MessagesResponse> => {
  const url = conversationId 
    ? `/api/v1/messages?conversation_id=${encodeURIComponent(conversationId)}`
    : '/api/v1/messages';
    
  const response = await fetch(url, {
    headers: {
      'Authorization': `Bearer ${apiKey}`
    }
  });
  
  if (!response.ok) {
    const errorData = await response.json() as ErrorResponse;
    throw new Error(errorData.error.message || 'Failed to fetch messages');
  }
  
  return await response.json() as MessagesResponse;
};
