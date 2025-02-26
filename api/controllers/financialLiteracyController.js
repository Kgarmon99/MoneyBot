const financialLiteracyService = require('../services/financialLiteracyService');

/**
 * Controller for handling financial literacy related requests
 */
const financialLiteracyController = {
  /**
   * Process a financial advice request
   * @param {object} req - The Express request object
   * @param {object} res - The Express response object
   */
  async getFinancialAdvice(req, res) {
    try {
      const { message, chatHistory } = req.body;
      
      if (!message) {
        return res.status(400).json({ 
          success: false, 
          message: 'Message is required' 
        });
      }

      const response = await financialLiteracyService.getFinancialAdvice(
        message, 
        chatHistory || []
      );
      
      return res.status(200).json(response);
    } catch (error) {
      console.error('Error in financial literacy controller:', error);
      return res.status(500).json({
        success: false,
        message: 'An error occurred while processing your request',
        error: error.message
      });
    }
  }
};

module.exports = financialLiteracyController;