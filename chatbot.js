const BACKEND_URL = 'https://api.openai.com/v1/chat/completions'; // OpenAI API endpoint

async function sendPrompt(prompt) {
  const chatBox = document.getElementById('chat-box');
  const userMessage = document.createElement('div');
  userMessage.className = 'user-message';
  userMessage.textContent = prompt;
  chatBox.appendChild(userMessage);

  try {
    const aiMessage = await getAIResponse(prompt);

    const aiMessageElement = document.createElement('div');
    aiMessageElement.className = 'ai-message';
    aiMessageElement.textContent = aiMessage;
    chatBox.appendChild(aiMessageElement);
  } catch (error) {
    console.error('Error getting AI response:', error);
    alert('Error getting response from OpenAI.');
  }

  chatBox.scrollTop = chatBox.scrollHeight;
}

async function sendMessage() {
  const chatInput = document.getElementById('chat-input');
  const message = chatInput.value;
  if (!message) return;

  chatInput.value = ''; // Clear input field
  await sendPrompt(message);
}

async function getAIResponse(prompt) {
  const API_KEY = 'YOUR_API_KEY_HERE'; // Replace with your actual API key

  try {
    const response = await fetch(BACKEND_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${API_KEY}`,
      },
      body: JSON.stringify({
        model: 'gpt-4',
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 150,
      }),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status}`);
    }

    const data = await response.json();
    return data.choices[0].message.content.trim();
  } catch (error) {
    console.error('Error in getAIResponse:', error);
    throw error;
  }
}
