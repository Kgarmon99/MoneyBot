// Simple server launch script
require('esbuild-register');
const app = require('./server/index.ts').default;

// This script is meant to be run directly: node server-direct.js
console.log("MoneyBot API server starting up...");