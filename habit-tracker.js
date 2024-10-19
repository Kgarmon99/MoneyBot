document.addEventListener('DOMContentLoaded', function() {
    let habitCounter = parseInt(localStorage.getItem('habitCounter')) || 0; // Initialize with saved value or 0
    let clickCount = 0; // Counter for click events

    initializeTracker();
    showGoalSetting(); // Ensure the goal-setting section is initially visible

    const setGoalButton = document.getElementById('set-goal');
    if (setGoalButton) {
        setGoalButton.addEventListener('click', setGoal);
    }

    const habitCircle = document.querySelector('.habit-circle');
    if (habitCircle) {
        habitCircle.addEventListener('click', toggleHabit);
    }

    const resetbutton = document.getElementById('reset-button');
    if (resetbutton) {
        resetbutton.addEventListener('click', resetCounter);
    }

    const increaseButton = document.getElementById('increase-counter');
    if (increaseButton) {
        increaseButton.addEventListener('click', increaseCounter);
    }

    function setGoal() {
        const goalInput = document.getElementById('goal-input');
        const goal = goalInput.value.trim();
        if (goal) {
            const goalDisplay = document.getElementById('goal-display');
            const goalTopDisplay = document.getElementById('goal-top-display');
            if (goalDisplay) {
                goalDisplay.textContent = goal;
            }
            if (goalTopDisplay) {
                goalTopDisplay.textContent = goal;
            }
            localStorage.setItem('goal', goal);
            goalInput.value = '';
            hideGoalSetting();
            showHabitCircle();
        } else {
            alert('Please enter a goal.');
        }
    }

    function toggleHabit() {
        const habitCircle = document.querySelector('.habit-circle');
        clickCount++;
        habitCircle.style.background = `conic-gradient(#00ff99 0% ${(clickCount / 3) * 100}%, transparent ${(clickCount / 3) * 100}% 100%)`;

        // Increment habit counter if the habit is completed
        if (clickCount === 3) {
            habitCounter++;
            localStorage.setItem('habitCounter', habitCounter); // Save updated counter
            showCelebration();
            clickCount = 0; // Reset click count
            updateStreak();
        }
    }

    function initializeTracker() {
        const savedGoal = localStorage.getItem('goal');
        if (savedGoal) {
            const goalDisplay = document.getElementById('goal-display');
            const goalTopDisplay = document.getElementById('goal-top-display');
            if (goalDisplay) {
                goalDisplay.textContent = savedGoal;
            }
            if (goalTopDisplay) {
                goalTopDisplay.textContent = savedGoal;
            }
            hideGoalSetting();
            showHabitCircle();
        }
        updateStreak();
    }

    function updateStreak() {
        const habitCounterDisplay = document.getElementById('habit-counter');
        if (habitCounterDisplay) {
            habitCounterDisplay.textContent = `Streak🔥: ${habitCounter}`;
        }
    }

    function showCelebration() {
        const animationContainer = document.getElementById('celebration-animation');
        if (animationContainer) {
            animationContainer.innerHTML = '<span class="celebration-animation">HABIT COMPLETE!!🚀🎉📈</span>';
            setTimeout(() => {
                animationContainer.innerHTML = '';
            }, 3000);
        }
    }

    function hideGoalSetting() {
        const goalSettingSection = document.querySelector('.goal-setting');
        if (goalSettingSection) {
            goalSettingSection.style.display = 'none';
        }
    }

    function showGoalSetting() {
        const goalSettingSection = document.querySelector('.goal-setting');
        if (goalSettingSection) {
            goalSettingSection.style.display = 'block';
        }
    }

    function showHabitCircle() {
        const habitCircle = document.querySelector('.habit-circle');
        if (habitCircle) {
            habitCircle.style.display = 'flex';
        }
    }

    function resetCounter() {
        habitCounter = 0;
        localStorage.setItem('habitCounter', habitCounter);
        updateStreak();
    }

    function increaseCounter() {
        habitCounter++;
        localStorage.setItem('habitCounter', habitCounter);
        updateStreak();
    }
});