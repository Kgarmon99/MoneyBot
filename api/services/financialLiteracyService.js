const openai = require('../config/openai');

/**
 * Financial Literacy Service - Provides financial advice and education through ChatGPT
 */
const financialLiteracyService = {
  /**
   * Get financial advice based on user input
   * @param {string} userInput - The user's question or prompt
   * @param {array} chatHistory - Previous conversation history (optional)
   * @returns {Promise<object>} - The AI response
   */
  async getFinancialAdvice(userInput, chatHistory = []) {
    try {
      // Prepare messages with financial literacy context
      const messages = [
        {
          role: 'system',
          content: `You are a financial literacy expert and coach. 
          Your goal is to provide accurate, educational, and helpful financial advice. 
          Focus on teaching fundamental financial concepts, budgeting strategies, 
          investment basics, debt management, and saving techniques. 
          Use simple language and explain financial terms. Provide practical steps 
          that users can take to improve their financial health. 
          Always encourage responsible financial habits and never recommend high-risk investments.`
        },
        ...chatHistory,
        { role: 'user', content: userInput }
      ];

      // Call OpenAI API
      const response = await openai.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: messages,
        temperature: 0.7,
        max_tokens: 500,
      });

      return {
        message: response.choices[0].message.content,
        success: true
      };
    } catch (error) {
      console.error('Error in financial literacy service:', error);
      return {
        message: 'Sorry, I encountered an error while processing your request. Please try again later.',
        success: false,
        error: error.message
      };
    }
  }
};

module.exports = financialLiteracyService;