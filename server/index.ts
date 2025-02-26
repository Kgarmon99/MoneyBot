import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { join } from 'path';
import { router } from './routes';

// Load environment variables
dotenv.config();

// Initialize express app
const app = express();
const port = process.env.PORT || 3000;

// Setup middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Add request ID middleware
app.use((req: express.Request, res: express.Response, next: express.NextFunction) => {
  (req as any).id = 'req_' + Math.random().toString(36).substring(2, 9);
  next();
});

// Mount API router
app.use('/api', router);

// Serve static files from client/dist in production
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(join(__dirname, '../client/dist')));
  
  // Handle client-side routing
  app.get('*', (req: express.Request, res: express.Response) => {
    res.sendFile(join(__dirname, '../client/dist/index.html'));
  });
}

// Health check endpoint
app.get('/health', (req: express.Request, res: express.Response) => {
  res.json({ status: 'ok' });
});

// Error handling middleware
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  
  res.status(err.status || 500).json({
    error: {
      code: err.code || 'server_error',
      message: err.message || 'An unexpected error occurred',
      status: err.status || 500,
      request_id: (req as any).id
    }
  });
});

// Check if OpenAI API key is available
if (!process.env.OPENAI_API_KEY) {
  console.warn('\x1b[33m%s\x1b[0m', 'Warning: OPENAI_API_KEY is not set. OpenAI API calls will fail.');
  console.warn('\x1b[33m%s\x1b[0m', 'Please set the OPENAI_API_KEY environment variable in the .env file.');
}

// Start server
const server = app.listen(Number(port), '0.0.0.0', () => {
  console.log(`MoneyBot API server listening on port ${port}`);
  console.log(`Server running at http://0.0.0.0:${port}`);
  console.log(`API endpoints available at http://0.0.0.0:${port}/api`);
  console.log(`Health check endpoint at http://0.0.0.0:${port}/health`);
});

export default app;