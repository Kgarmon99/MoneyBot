import { exec } from 'child_process';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

console.log('Starting MoneyBot API server...');

// Start the server
exec('node -r esbuild-register server/index.ts', (error, stdout, stderr) => {
  if (error) {
    console.error(`Error: ${error.message}`);
    return;
  }
  
  if (stderr) {
    console.error(`stderr: ${stderr}`);
    return;
  }
  
  console.log(stdout);
});