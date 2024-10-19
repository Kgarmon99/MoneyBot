// QuoteManager module
const QuoteManager = (function () {
  const quotes = [
    { text: "Invest in your dreams. Grind now. Shine later.", author: "Unknown" },
    { text: "The best time to plant a tree was 20 years ago. The second best time is now.", author: "Chinese Proverb" },
    { text: "Only the paranoid survive.", author: "Andy Grove" },
    { text: "It's hard to beat a person who never gives up.", author: "Babe Ruth" },
    { text: "I wake up every morning and think to myself, 'how far can I push this company in the next 24 hours.'", author: "Leah Busque" },
    { text: "Time is more valuable than money. You can get more money, but you cannot get more time.", author: "Jim Rohn" },
    { text: "An investment in knowledge pays the best interest.", author: "Benjamin Franklin" },
    { text: "The stock market is filled with individuals who know the price of everything, but the value of nothing.", author: "Philip Fisher" },
    { text: "Do not save what is left after spending, but spend what is left after saving.", author: "Warren Buffett" },
    { text: "Wealth is not his that has it, but his that enjoys it.", author: "Benjamin Franklin" },
    { text: "It is not the man who has too little, but the man who craves more, that is poor.", author: "Seneca" },
    { text: "The goal isn't more money. The goal is living life on your terms.", author: "Chris Brogan" },
    { text: "Money is a terrible master but an excellent servant.", author: "P.T. Barnum" },
    { text: "Rich people have small TVs and big libraries, and poor people have small libraries and big TVs.", author: "Zig Ziglar" },
    { text: "Never spend your money before you have earned it.", author: "Thomas Jefferson" },
    { text: "Money often costs too much.", author: "Ralph Waldo Emerson" },
    { text: "A wise person should have money in their head, but not in their heart.", author: "Jonathan Swift" },
    { text: "Wealth consists not in having great possessions, but in having few wants.", author: "Epictetus" },
    { text: "Opportunity is missed by most people because it is dressed in overalls and looks like work.", author: "Thomas Edison" },
    { text: "A budget tells us what we can't afford, but it doesn't keep us from buying it.", author: "William Feather" },
  ];

  function getRandomQuote() {
    const randomIndex = Math.floor(Math.random() * quotes.length);
    return quotes[randomIndex];
  }

  function displayQuote() {
    const quote = getRandomQuote();
    document.getElementById("quote-display").innerHTML = `<p>"${quote.text}" - ${quote.author}</p>`;
  }

  return {
    displayQuote: displayQuote,
  };
})();

document.getElementById("generate-more-button").addEventListener("click", QuoteManager.displayQuote);

document.addEventListener('DOMContentLoaded', () => {
  const streak = initializeStreak();
  displayStreak(streak);
});

function initializeStreak() {
  const today = new Date().toDateString();
  const lastUsed = localStorage.getItem('lastUsedDate');
  let streak = parseInt(localStorage.getItem('streak'), 10) || 0;

  if (!lastUsed) {
    // First time usage
    streak = 1;
  } else if (new Date(lastUsed).toDateString() === today) {
    // Already used today, do nothing
    return streak;
  } else if (new Date(lastUsed).getTime() === new Date(today).setDate(new Date(today).getDate() - 1)) {
    // Used yesterday, increase the streak
    streak++;
  } else {
    // Missed a day, reset streak
    streak = 1;
  }

  // Update the streak and last used date
  localStorage.setItem('lastUsedDate', today);
  localStorage.setItem('streak', streak);

  return streak;
}

function displayStreak(streak) {
  const streakElement = document.getElementById('streakDisplay');
  if (streakElement) {
    streakElement.innerText = `🔥: ${streak}`;
  }
}

document.addEventListener('DOMContentLoaded', () => {
  loadTopPriorities();
  displayPriorityForToday(); // Ensure this is called on page load
});

async function loadTopPriorities() {
  try {
    const response = await fetch('http://localhost:3000/api/tasks/top-priorities');
    const priorities = await response.json();
    displayPriorities(priorities);
  } catch (error) {
    console.error('Error loading top priorities:', error);
  }
}

function displayPriorities(priorities) {
  const priorityList = document.getElementById('priorityList');
  priorityList.innerHTML = '';

  priorities.forEach(task => {
    const li = document.createElement('li');
    li.textContent = `${task.task_name} - Priority: ${task.priority}`;
    priorityList.appendChild(li);
  });
}

function displayPriorityForToday() {
  const today = new Date().toISOString().split('T')[0];
  const task = JSON.parse(localStorage.getItem('todayPriority'));

  const priorityDisplayHome = document.getElementById('priorityDisplayHome');
  if (task && task.date === today) {
    priorityDisplayHome.textContent = `Today's Top Goal: ${task.task_name}`;
    priorityDisplayHome.classList.remove('no-goal'); // Ensure the no-goal class is removed
  } else {
    priorityDisplayHome.textContent = 'No Goal set for today:(.';
    priorityDisplayHome.classList.add('no-goal'); // Add class for no goal
  }
}