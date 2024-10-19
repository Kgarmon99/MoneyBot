document.addEventListener('DOMContentLoaded', function() {
    const calculateButton = document.getElementById('calculateButton');
    calculateButton.addEventListener('click', calculateNetWorth);

    function calculateNetWorth() {
        // Fetch input values
        const cash = parseFloat(document.getElementById('cash').value) || 0;
        const investments = parseFloat(document.getElementById('investments').value) || 0;
        const property = parseFloat(document.getElementById('property').value) || 0;
        const loans = parseFloat(document.getElementById('loan').value) || 0;

        // Calculate net worth
        const assets = cash + investments + property;
        const liabilities = loans;
        const netWorth = assets - liabilities;

        // Display net worth
        const netWorthElement = document.getElementById('netWorth');
        netWorthElement.textContent = `$${netWorth.toFixed(2)}`;
        netWorthElement.parentElement.style.display = 'block'; // Show result container
    }
});
