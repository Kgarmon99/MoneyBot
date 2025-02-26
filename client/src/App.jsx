import React from 'react';
import { Route, Switch } from 'wouter';
import FinancialChatbot from './components/FinancialLiteracy/FinancialChatbot';

/**
 * Main App component
 */
const App = () => {
  return (
    <div className="min-h-screen bg-gray-100 p-4">
      <header className="max-w-4xl mx-auto mb-8 text-center">
        <h1 className="text-3xl font-bold text-blue-800 mb-2">MoneyBot Financial Literacy</h1>
        <p className="text-gray-600">Your AI-powered financial literacy assistant</p>
      </header>

      <main className="max-w-4xl mx-auto">
        <Switch>
          <Route path="/" component={FinancialChatbot} />
          {/* Add more routes as needed */}
        </Switch>
      </main>

      <footer className="max-w-4xl mx-auto mt-12 text-center text-gray-500 text-sm">
        <p>© {new Date().getFullYear()} MoneyBot - AI-Powered Financial Literacy</p>
      </footer>
    </div>
  );
};

export default App;