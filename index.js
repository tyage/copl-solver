const readline = require('readline');
const fs = require('fs');
const PEG = require('pegjs');

const parserFile = process.argv[2];
const parser = PEG.buildParser(fs.readFileSync(parserFile).toString());

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.on('line', (input) => {
  const result = parser.parse(input);
  console.log(result);
});
