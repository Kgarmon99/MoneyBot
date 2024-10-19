document.addEventListener('DOMContentLoaded', function() {
    const calculateButton = document.getElementById('calculateButton');
    calculateButton.addEventListener('click', calculateBudget);

    function calculateBudget() {
        // Fetch input values
        const incomeAmount = parseFloat(document.getElementById('incomeAmount').value);
        const expenses = parseFloat(document.getElementById('expenses').value);
        const savings = parseFloat(document.getElementById('savings').value);
        const incomeFrequency = document.getElementById('incomeFrequency').value;

        // Calculate total income based on frequency
        let totalIncome = 0;
        switch (incomeFrequency) {
            case 'daily':
                totalIncome = incomeAmount * 365; // Assuming 365 days in a year
                break;
            case 'weekly':
                totalIncome = incomeAmount * 52; // Assuming 52 weeks in a year
                break;
            case 'monthly':
                totalIncome = incomeAmount * 12; // Assuming 12 months in a year
                break;
            case 'quarterly':
                totalIncome = incomeAmount * 4; // Assuming 4 quarters in a year
                break;
            case 'biyearly':
                totalIncome = incomeAmount * 2; // Every 6 months
                break;
            case 'yearly':
                totalIncome = incomeAmount;
                break;
            default:
                totalIncome = incomeAmount;
        }

        // Calculate total budget, expenses, savings, and remaining
        const totalBudget = totalIncome - expenses - savings;
        const expensesPercentage = (expenses / totalIncome) * 100;
        const savingsPercentage = (savings / totalIncome) * 100;
        const remainingPercentage = ((totalIncome - expenses - savings) / totalIncome) * 100;

        // Update pie chart
        updatePieChart(expensesPercentage, savingsPercentage, remainingPercentage);

        // Update breakdown section
        updateBreakdown(totalIncome, totalBudget);
    }

    function updatePieChart(expensesPercentage, savingsPercentage, remainingPercentage) {
        const ctx = document.getElementById('budgetChart').getContext('2d');
        const chartData = [expensesPercentage, savingsPercentage, remainingPercentage];
        const chartLabels = ['Expenses', 'Savings', 'Remaining'];

        if (window.myChart != null) {
            window.myChart.destroy();
        }

        window.myChart = new Chart(ctx, {
            type: 'pie',
            data: {
                labels: chartLabels,
                datasets: [{
                    data: chartData,
                    backgroundColor: ['#ff0000', '#ffff00', '#0000ff'],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                legend: {
                    position: 'bottom',
                    labels: {
                        fontColor: 'white'
                    }
                }
            }
        });
    }

    function updateBreakdown(totalIncome, totalBudget) {
        const dailyIncome = totalIncome / 365;
        const weeklyIncome = totalIncome / 52;
        const monthlyIncome = totalIncome / 12;
        const quarterlyIncome = totalIncome / 4;
        const biyearlyIncome = totalIncome / 2;
        const yearlyIncome = totalIncome;

        document.getElementById('dailyIncome').textContent = dailyIncome.toFixed(2);
        document.getElementById('weeklyIncome').textContent = weeklyIncome.toFixed(2);
        document.getElementById('monthlyIncome').textContent = monthlyIncome.toFixed(2);
        document.getElementById('quarterlyIncome').textContent = quarterlyIncome.toFixed(2);
        document.getElementById('biyearlyIncome').textContent = biyearlyIncome.toFixed(2);
        document.getElementById('yearlyIncome').textContent = yearlyIncome.toFixed(2);

        // Display total budget and expenses in the breakdown
        document.getElementById('totalBudget').textContent = totalBudget.toFixed(2);
        document.getElementById('totalExpenses').textContent = expenses.toFixed(2);
    }
});
