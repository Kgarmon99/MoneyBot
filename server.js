const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const axios = require('axios');

const app = express();
const PORT = 3000;

app.use(cors()); // Enable CORS for all routes
app.use(bodyParser.json());

app.post('/api/chat', async (req, res) => {
    const { prompt } = req.body;

    try {
        const response = await axios.post('https://api.openai.com/v1/chat/completions', {
            model: 'gpt-4',
            messages: [{ role: 'user', content: prompt }],
            max_tokens: 150,
        }, {
            headers: {
                'Authorization': `Bearer YOUR_API_KEY_HERE`,
                'Content-Type': 'application/json',
            },
        });

        const message = response.data.choices[0].message.content.trim();
        res.json({ message });
    } catch (error) {
        console.error('Error getting AI response:', error);
        res.status(500).send('Error getting response from OpenAI.');
    }
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
