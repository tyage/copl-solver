const readline = require('readline');
const parser = require('./copl.js');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.on('line', (input) => {
  const result = parser.parse(input);
  console.log(result);
});
