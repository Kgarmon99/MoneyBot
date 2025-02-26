import { useState, useCallback } from 'react';

/**
 * Custom hook for managing financial literacy chat functionality
 * 
 * @returns {Object} Chat state and functions
 */
const useFinancialChat = () => {
  const [messages, setMessages] = useState([
    {
      role: 'assistant',
      content: 'Hello! I\'m your financial literacy assistant. Ask me anything about personal finance, budgeting, investing, or saving money!'
    }
  ]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);

  /**
   * Send a message to the financial literacy API
   * @param {string} message - The user's message
   */
  const sendMessage = useCallback(async (message) => {
    if (!message.trim()) return;
    
    // Add user message to chat
    const userMessage = { role: 'user', content: message };
    setMessages(prev => [...prev, userMessage]);
    setIsLoading(true);
    setError(null);

    try {
      // Convert messages to the format expected by the API
      const chatHistory = messages.map(msg => ({
        role: msg.role,
        content: msg.content
      }));

      // Send request to the API
      const response = await fetch('/api/financial-literacy/advice', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message,
          chatHistory
        }),
      });

      const data = await response.json();
      
      if (!response.ok) {
        throw new Error(data.message || 'Failed to get response');
      }

      // Add assistant response to chat
      setMessages(prev => [
        ...prev, 
        { role: 'assistant', content: data.message }
      ]);
    } catch (err) {
      console.error('Error getting financial advice:', err);
      setError('Sorry, there was an error processing your request. Please try again.');
    } finally {
      setIsLoading(false);
    }
  }, [messages]);

  /**
   * Reset the conversation
   */
  const resetChat = useCallback(() => {
    setMessages([
      {
        role: 'assistant',
        content: 'Hello! I\'m your financial literacy assistant. Ask me anything about personal finance, budgeting, investing, or saving money!'
      }
    ]);
    setError(null);
  }, []);

  return {
    messages,
    isLoading,
    error,
    sendMessage,
    resetChat
  };
};

export default useFinancialChat;