
// script.js

const tools = [
    {
        title: "Budget Builder",
        description: "Manage your finances with our intuitive budget builder.",
        link: "#budget-builder"
    },
    {
        title: "Goal Setter",
        description: "Set and achieve your financial goals with ease.",
        link: "#goal-setter"
    },
    {
        title: "Investment Tracker",
        description: "Keep track of your investments and their performance.",
        link: "#investment-tracker"
    },
    {
        title: "Savings Calculator",
        description: "Calculate your savings over time with ease.",
        link: "#savings-calculator"
    },
    {
        title: "Debt Repayment Planner",
        description: "Plan your debt repayment strategy effectively.",
        link: "#debt-repayment"
    },
    // Add more tools here...
];

const toolGrid = document.querySelector('.tool-grid');

tools.forEach(tool => {
    const card = document.createElement('div');
    card.classList.add('tool-card');

    const title = document.createElement('h2');
    title.textContent = tool.title;

    const description = document.createElement('p');
    description.textContent = tool.description;

    const button = document.createElement('a');
    button.href = tool.link;
    button.classList.add('tool-button');
    button.textContent = "Try Now";

    card.appendChild(title);
    card.appendChild(description);
    card.appendChild(button);
    toolGrid.appendChild(card);
});

// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "",
  authDomain: "moneybot-3a066.firebaseapp.com",
  projectId: "moneybot-3a066",
  storageBucket: "moneybot-3a066.appspot.com",
  messagingSenderId: "991072303310",
  appId: "1:991072303310:web:df8afab2f3b62bf410b89f",
  measurementId: "G-7WTK70TBJP"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);

