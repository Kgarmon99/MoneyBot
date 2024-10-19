const learningPath = [
  {
    title: "Learn the Language of Money",
    icon: "💬",
    levels: [
      { title: "Currency Basics", content: "https://www.youtube.com/watch?v=GwAIu-RA_WA&ab_channel=MiacademyLearningChannel" },
      { title: "Financial Jargon", content: "https://www.youtube.com/watch?v=GwAIu-RA_WA&ab_channel=MiacademyLearningChannel" },
      { title: "Economic Terms", content: "https://www.youtube.com/embed/def456" },
      { title: "Banking Vocabulary", content: "https://www.youtube.com/embed/ghi789" },
      { title: "Investment Lingo", content: "https://www.youtube.com/embed/jkl012" }
    ]
  },
  {
    title: "Understand Money Terms",
    icon: "📚",
    levels: [
      { title: "Income vs Expenses", content: "https://www.youtube.com/embed/mno345" },
      { title: "Assets vs Liabilities", content: "https://www.youtube.com/embed/pqr678" },
      { title: "Credit and Debt", content: "https://www.youtube.com/embed/stu901" },
      { title: "Interest Rates", content: "https://www.youtube.com/embed/vwx234" },
      { title: "Financial Statements", content: "https://www.youtube.com/embed/yzx567" }
    ]
  },
  {
    title: "Understand Importance of Budgeting",
    icon: "📊",
    levels: [
      { title: "Tracking Expenses", content: "https://www.youtube.com/embed/abc890" },
      { title: "Setting Financial Goals", content: "https://www.youtube.com/embed/def901" },
      { title: "Creating a Budget", content: "https://www.youtube.com/embed/ghi012" },
      { title: "Sticking to Your Plan", content: "https://www.youtube.com/embed/jkl345" },
      { title: "Adjusting and Reviewing", content: "https://www.youtube.com/embed/mno678" }
    ]
  }
];

let currentLevel = 1;
let xp = 0;
let streakDays = 0;
let lastCompletedDate = null;

function renderLearningPath() {
  const mainElement = document.getElementById('learning-path');
  mainElement.innerHTML = '';

  learningPath.forEach((section, sectionIndex) => {
    const sectionElement = document.createElement('div');
    sectionElement.className = 'section';

    const titleElement = document.createElement('h2');
    titleElement.className = 'section-title';
    titleElement.innerHTML = `${section.icon} ${section.title}`;

    sectionElement.appendChild(titleElement);

    const levelsElement = document.createElement('ul');
    levelsElement.className = 'levels';

    section.levels.forEach((level, levelIndex) => {
      const levelElement = document.createElement('li');
      levelElement.className = 'level';

      const globalLevelIndex = sectionIndex * 5 + levelIndex + 1;
      const isCompleted = globalLevelIndex < currentLevel;
      const isCurrentLevel = globalLevelIndex === currentLevel;

      levelElement.classList.add(isCompleted ? 'completed' : (isCurrentLevel ? 'current' : 'locked'));

      const levelContent = `
        <span class="level-icon">${isCompleted ? '✅' : (isCurrentLevel ? '🔓' : '🔒')}</span>
        <span class="level-title">${level.title}</span>
      `;

      levelElement.innerHTML = levelContent;

      if (isCurrentLevel) {
        levelElement.addEventListener('click', () => startLevel(globalLevelIndex, level.content));
      }

      levelsElement.appendChild(levelElement);
    });

    sectionElement.appendChild(levelsElement);
    mainElement.appendChild(sectionElement);
  });

  updateProgressBar();
}

function startLevel(levelIndex, content) {
  // Show the content modal with video/content for the selected level
  showContentModal(content);

  // Add a listener to complete the level when the video/modal is closed
  const closeButton = document.getElementById('close-modal');
  closeButton.onclick = () => {
    completeLevel(levelIndex); // Complete the level only after closing the modal
  };
}

function completeLevel(levelIndex) {
  currentLevel = levelIndex + 1;
  xp += 50; // Award 50 XP for completing a level

  updateProgressBar();
  showLevelCompleteModal();
  renderLearningPath();

  // Update streak
  const today = new Date().toDateString();
  if (lastCompletedDate !== today) {
    streakDays++;
    lastCompletedDate = today;
  }
}

function updateProgressBar() {
  const levelElement = document.getElementById('current-level');
  levelElement.textContent = currentLevel;

  const xpProgressElement = document.getElementById('xp-progress');
  const xpPercentage = (xp % 100) + '%';
  xpProgressElement.style.width = xpPercentage;
}

function showLevelCompleteModal() {
  const modal = document.getElementById('level-complete-modal');
  const xpEarnedElement = document.getElementById('xp-earned');
  xpEarnedElement.textContent = '50';

  modal.style.display = 'flex';

  const claimRewardButton = document.getElementById('claim-reward');
  claimRewardButton.onclick = () => {
    modal.style.display = 'none';
  };
}

function showContentModal(content) {
  const modal = document.getElementById('content-modal');
  const contentContainer = document.getElementById('modal-content');

  // Embed the video content in the iframe
  contentContainer.innerHTML = `<iframe width="560" height="315" src="${content}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>`;

  modal.style.display = 'flex';

  const closeButton = document.getElementById('close-modal');
  closeButton.onclick = () => {
    modal.style.display = 'none';
  };
}

// Initialize the learning path
renderLearningPath();

// Add GSAP animations
gsap.registerPlugin(ScrollTrigger);

gsap.utils.toArray('.section').forEach((section) => {
  gsap.from(section, {
    opacity: 0,
    y: 50,
    duration: 1,
    scrollTrigger: {
      trigger: section,
      start: 'top 80%',
      end: 'top 20%',
      scrub: 1,
    }
  });
});

// Add event listeners for nav buttons
const navButtons = document.querySelectorAll('.nav-button');
navButtons.forEach(button => {
  button.addEventListener('click', () => {
    const action = button.getAttribute('data-tooltip');
    console.log(`${action} button clicked`);

    // Implement the action for each button
    switch (action) {
      case 'Home':
        window.location.href = 'index.html'; // Navigate to home page
        break;
      case 'Library':
        window.location.href = 'library.html'; // Navigate to library page
        break;
      case 'Chatbot':
        window.location.href = 'Chatbot2.html'; // Navigate to chatbot page
        break;
      case 'Tools':
        window.location.href = 'tools.html'; // Navigate to tools page
      default:
        console.warn('Unknown action:', action); // Handle unknown actions
    }
  });
});
