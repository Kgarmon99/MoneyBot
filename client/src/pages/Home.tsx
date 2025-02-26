import React, { useState } from 'react';
import { Link } from 'wouter';
import { useQuery, useMutation } from '@tanstack/react-query';
import { getModels, sendChatCompletion } from '../lib/openai';
import { queryClient } from '../lib/queryClient';
import { truncateText } from '../lib/utils';

/**
 * Home Page Component
 */
const Home = () => {
  const [question, setQuestion] = useState('');
  const [conversation, setConversation] = useState<{
    messages: Array<{ role: 'user' | 'assistant'; content: string }>;
  }>({
    messages: [],
  });

  // Fetch available models
  const { data: modelsData, isLoading: isLoadingModels } = useQuery({
    queryKey: ['/api/models'],
    queryFn: getModels,
  });

  // Chat completion mutation
  const chatMutation = useMutation({
    mutationFn: sendChatCompletion,
    onSuccess: (data) => {
      // Add assistant's response to conversation
      if (data.choices && data.choices.length > 0) {
        setConversation((prev) => ({
          messages: [
            ...prev.messages,
            {
              role: 'assistant',
              content: data.choices[0].message.content || '',
            },
          ],
        }));
      }
    },
  });

  // Handle form submission
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!question.trim()) return;
    
    // Add user message to conversation
    setConversation((prev) => ({
      messages: [
        ...prev.messages,
        { role: 'user', content: question },
      ],
    }));
    
    // Send chat completion request
    chatMutation.mutate({
      model: 'gpt-4o', // the newest OpenAI model is "gpt-4o" which was released May 13, 2024
      messages: [
        {
          role: 'system',
          content: 'You are MoneyBot, an advanced AI assistant specializing in financial advice. You provide helpful, accurate, and concise information about personal finance, investments, savings, budgeting, and other money-related topics. When you don\'t know something, you admit it rather than making up information.',
        },
        ...conversation.messages,
        { role: 'user', content: question },
      ],
    });
    
    // Clear input
    setQuestion('');
  };

  return (
    <div className="container mx-auto px-4 py-8 max-w-4xl">
      <header className="mb-8 text-center">
        <h1 className="text-3xl font-bold mb-2 text-green-700">MoneyBot API</h1>
        <p className="text-gray-600 dark:text-gray-300">
          Your AI-powered financial co-pilot
        </p>
      </header>

      <div className="flex flex-col md:flex-row gap-8">
        <main className="flex-1">
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 mb-6">
            <h2 className="text-xl font-semibold mb-4 text-green-700">Chat with MoneyBot</h2>
            
            <div className="border rounded-lg p-4 mb-4 h-80 overflow-y-auto">
              {conversation.messages.length === 0 ? (
                <div className="text-center text-gray-500 dark:text-gray-400 h-full flex flex-col justify-center">
                  <p>No messages yet. Ask MoneyBot something about finance!</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {conversation.messages.map((message, index) => (
                    <div
                      key={index}
                      className={`p-3 rounded-lg ${
                        message.role === 'user'
                          ? 'bg-blue-100 dark:bg-blue-900 ml-8'
                          : 'bg-green-100 dark:bg-green-900 mr-8'
                      }`}
                    >
                      <div className="font-semibold mb-1">
                        {message.role === 'user' ? 'You' : 'MoneyBot'}
                      </div>
                      <div className="whitespace-pre-wrap">{message.content}</div>
                    </div>
                  ))}
                </div>
              )}
            </div>
            
            <form onSubmit={handleSubmit} className="flex gap-2">
              <input
                type="text"
                value={question}
                onChange={(e) => setQuestion(e.target.value)}
                placeholder="Ask about budgeting, investing, or savings..."
                className="flex-1 border rounded-md px-4 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
                disabled={chatMutation.isPending}
              />
              <button
                type="submit"
                className="bg-green-600 text-white rounded-md px-4 py-2 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500"
                disabled={chatMutation.isPending || !question.trim()}
              >
                {chatMutation.isPending ? 'Sending...' : 'Send'}
              </button>
            </form>
          </div>
        </main>
        
        <aside className="md:w-64">
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold mb-4 text-green-700">API Resources</h2>
            <ul className="space-y-2">
              <li>
                <Link href="/api-playground">
                  <a className="text-blue-600 hover:underline">API Playground</a>
                </Link>
              </li>
              <li>
                <a 
                  href="https://github.com/Kgarmon99/Moneybotios2" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="text-blue-600 hover:underline"
                >
                  iOS App Repository
                </a>
              </li>
            </ul>
            
            <h3 className="text-lg font-semibold mt-6 mb-2">Available Models</h3>
            {isLoadingModels ? (
              <p className="text-gray-500">Loading models...</p>
            ) : (
              <ul className="space-y-2">
                {modelsData?.data.map((model) => (
                  <li key={model.id} className="text-sm">
                    <div className="font-medium">{model.name}</div>
                    <div className="text-gray-500 dark:text-gray-400">
                      {truncateText(model.description, 60)}
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </aside>
      </div>
    </div>
  );
};

export default Home;