import OpenAI from "openai";

// the newest OpenAI model is "gpt-4o" which was released May 13, 2024. do not change this unless explicitly requested by the user
export const OPENAI_MODEL = "gpt-4o";

// Message type for OpenAI API
export interface Message {
  role: "system" | "user" | "assistant";
  content: string;
}

// Error response interface
export interface ErrorResponse {
  error: {
    code: string;
    message: string;
    status: number;
    request_id: string;
  };
}

// Chat completion request interface
export interface ChatCompletionRequest {
  messages: Message[];
  model?: string;
  temperature?: number;
  max_tokens?: number;
  conversation_id?: string;
}

// Financial advice request interface
export interface FinancialAdviceRequest {
  topic?: string;
  question: string;
  userContext?: {
    experience?: string;
    age?: number;
    hasDebt?: boolean;
    hasInvestments?: boolean;
    monthlyIncome?: number;
  };
}

// Financial advice response interface
export interface FinancialAdviceResponse {
  advice: string;
  topic?: string;
  conversation_id: string;
  model: string;
}

// Initialize the OpenAI client
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

/**
 * Send a chat completion request to the OpenAI API
 */
export const sendChatCompletion = async (
  request: ChatCompletionRequest,
  options: RequestInit = {}
) => {
  const response = await fetch('/api/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(request),
    ...options,
  });

  if (!response.ok) {
    const errorData: ErrorResponse = await response.json();
    throw new Error(errorData.error.message || 'Failed to get chat completion');
  }

  return response.json();
};

/**
 * Get personalized financial advice
 */
export const getFinancialAdvice = async (
  request: FinancialAdviceRequest,
  options: RequestInit = {}
): Promise<FinancialAdviceResponse> => {
  const response = await fetch('/api/financial-advice', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(request),
    ...options,
  });

  if (!response.ok) {
    const errorData: ErrorResponse = await response.json();
    throw new Error(errorData.error.message || 'Failed to get financial advice');
  }

  return response.json();
};

// Direct OpenAI API functions for server-side use
export { openai };