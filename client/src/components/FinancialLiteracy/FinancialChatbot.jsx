import React, { useState, useRef, useEffect } from 'react';
import { Send, RefreshCw } from 'lucide-react';

/**
 * FinancialChatbot Component - A chatbot interface for financial literacy
 * 
 * This component provides a user interface for interacting with the financial
 * literacy AI assistant. Users can ask financial questions and receive
 * educational responses.
 */
const FinancialChatbot = () => {
  const [messages, setMessages] = useState([
    {
      role: 'assistant',
      content: 'Hello! I\'m your financial literacy assistant. Ask me anything about personal finance, budgeting, investing, or saving money!'
    }
  ]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);
  const messagesEndRef = useRef(null);

  // Auto-scroll to the bottom of the chat
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  // Handle sending a message
  const handleSendMessage = async (e) => {
    e.preventDefault();
    
    if (!input.trim()) return;
    
    // Add user message to chat
    const userMessage = { role: 'user', content: input };
    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setIsLoading(true);
    setError(null);

    try {
      // Prepare chat history for API
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
          message: input,
          chatHistory: chatHistory
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
  };

  // Reset the conversation
  const handleReset = () => {
    setMessages([
      {
        role: 'assistant',
        content: 'Hello! I\'m your financial literacy assistant. Ask me anything about personal finance, budgeting, investing, or saving money!'
      }
    ]);
    setError(null);
  };

  return (
    <div className="flex flex-col h-[600px] w-full max-w-2xl mx-auto rounded-lg border shadow-md bg-white">
      {/* Header */}
      <div className="p-4 border-b bg-blue-600 text-white rounded-t-lg flex justify-between items-center">
        <h2 className="text-xl font-semibold">Financial Literacy Assistant</h2>
        <button 
          onClick={handleReset}
          className="p-2 rounded-full hover:bg-blue-700 transition-colors"
          title="Reset conversation"
        >
          <RefreshCw size={18} />
        </button>
      </div>
      
      {/* Messages Container */}
      <div className="flex-1 p-4 overflow-y-auto bg-gray-50">
        {messages.map((message, index) => (
          <div 
            key={index} 
            className={`mb-4 ${
              message.role === 'user' 
                ? 'flex justify-end' 
                : 'flex justify-start'
            }`}
          >
            <div 
              className={`p-3 rounded-lg max-w-[80%] ${
                message.role === 'user'
                  ? 'bg-blue-500 text-white rounded-br-none'
                  : 'bg-white border border-gray-200 rounded-bl-none'
              }`}
            >
              <p className="whitespace-pre-wrap">{message.content}</p>
            </div>
          </div>
        ))}
        
        {isLoading && (
          <div className="flex justify-start mb-4">
            <div className="bg-white border border-gray-200 p-3 rounded-lg rounded-bl-none">
              <div className="flex items-center space-x-2">
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0ms' }}></div>
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '300ms' }}></div>
                <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '600ms' }}></div>
              </div>
            </div>
          </div>
        )}
        
        {error && (
          <div className="flex justify-center mb-4">
            <div className="bg-red-100 border border-red-300 text-red-700 p-3 rounded-lg">
              <p>{error}</p>
            </div>
          </div>
        )}
        
        <div ref={messagesEndRef} />
      </div>
      
      {/* Input Form */}
      <form onSubmit={handleSendMessage} className="border-t p-4 bg-white rounded-b-lg">
        <div className="flex space-x-2">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            disabled={isLoading}
            placeholder="Ask about budgeting, investing, saving..."
            className="flex-1 p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <button
            type="submit"
            disabled={isLoading || !input.trim()}
            className={`p-2 rounded-lg ${
              isLoading || !input.trim()
                ? 'bg-gray-300 cursor-not-allowed'
                : 'bg-blue-600 text-white hover:bg-blue-700'
            }`}
          >
            <Send size={20} />
          </button>
        </div>
      </form>
    </div>
  );
};

export default FinancialChatbot;