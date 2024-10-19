// priorities.js
document.addEventListener('DOMContentLoaded', () => {
    displayPriorityForToday();

    const taskForm = document.getElementById('taskForm');
    taskForm.addEventListener('submit', (e) => {
        e.preventDefault();
        setPriority();
    });
});

function setPriority() {
    const taskName = document.getElementById('taskName').value;
    const date = document.getElementById('date').value;

    if (!taskName || !date) {
        alert('Please fill in all fields.');
        return;
    }

    const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD format
    const task = { task_name: taskName, date: date };

    if (date !== today) {
        alert('You can only set the priority for today.');
        return;
    }

    localStorage.setItem('todayPriority', JSON.stringify(task));
    displayPriorityForToday();
    updateHomePage();

    document.getElementById('taskName').value = '';
    document.getElementById('date').value = '';
}

function displayPriorityForToday() {
    const today = new Date().toISOString().split('T')[0];
    const task = JSON.parse(localStorage.getItem('todayPriority'));

    const priorityDisplay = document.getElementById('priorityDisplay');
    if (task && task.date === today) {
        priorityDisplay.textContent = `: ${task.task_name}`;
    } else {
        priorityDisplay.textContent = 'No priority set for today.';
    }
}

function updateHomePage() {
    // This function assumes the home page has an element with id 'priorityDisplayHome'
    const homePageUrl = 'index.html'; // Adjust if your homepage has a different name or location
    const task = JSON.parse(localStorage.getItem('todayPriority'));

    if (task) {
        fetch(homePageUrl)
            .then(response => response.text())
            .then(html => {
                const parser = new DOMParser();
                const doc = parser.parseFromString(html, 'text/html');
                const priorityDisplayHome = doc.getElementById('priorityDisplayHome');

                if (priorityDisplayHome) {
                    priorityDisplayHome.textContent = `: ${task.task_name}`;
                }

                // Optionally, you can save this updated content back to the server
            });
    }
}