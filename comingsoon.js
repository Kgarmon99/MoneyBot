// Countdown Timer
const endDate = new Date('2024-12-31T00:00:00').getTime();  // Set your target date here

function countdown() {
    const now = new Date().getTime();
    const timeLeft = endDate - now;

    const days = Math.floor(timeLeft / (1000 * 60 * 60 * 24));
    const hours = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((timeLeft % (1000 * 60)) / 1000);

    document.getElementById('days').innerHTML = days;
    document.getElementById('hours').innerHTML = hours;
    document.getElementById('minutes').innerHTML = minutes;
    document.getElementById('seconds').innerHTML = seconds;

    if (timeLeft < 0) {
        clearInterval(timerInterval);
        document.getElementById('timer').innerHTML = 'Launched!';
    }
}

const timerInterval = setInterval(countdown, 1000);

// Timeline Feature Data
const timelineData = [
    { title: 'Budget Builder', description: 'Plan and track your personal budgets.', releaseDate: '2024-10-15' },
    { title: 'Goal Setter', description: 'Set SMART financial goals.', releaseDate: '2024-11-01' },
    { title: 'Investment Tracker', description: 'Monitor and manage your investments.', releaseDate: '2024-11-20' }
];

// Generate Timeline
function generateTimeline() {
    const timelineList = document.getElementById('timeline-list');
    timelineData.forEach(feature => {
        const li = document.createElement('li');
        li.classList.add('timeline-item');
        li.innerHTML = `
            <h3>${feature.title}</h3>
            <p>${feature.description}</p>
            <p><strong>Release Date:</strong> ${feature.releaseDate}</p>
        `;
        timelineList.appendChild(li);
    });
}

// Call the function to populate the timeline
generateTimeline();
