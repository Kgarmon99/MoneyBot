const express = require('express');
const financialLiteracyController = require('../controllers/financialLiteracyController');

const router = express.Router();

// Route for getting financial advice
router.post('/advice', financialLiteracyController.getFinancialAdvice);

module.exports = router;