import React from 'react';
import ReactDOM from 'react-dom/client';
import { QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { Switch, Route } from 'wouter';
import { queryClient } from './lib/queryClient';
import Home from './pages/Home';
import ApiPlayground from './pages/ApiPlayground';
import './index.css';

// Create app component
function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
        <Switch>
          <Route path="/" component={Home} />
          <Route path="/api-playground" component={ApiPlayground} />
        </Switch>
      </div>
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  );
}

// Render app
ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);