const readline = require('readline');
const fs = require('fs');
const PEG = require('pegjs');

const parserFile = process.argv[2];
// XXX: f*ckin pegjs added spaces to the parser program
const parser = PEG.buildParser(fs.readFileSync(parserFile).toString());

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

fs.writeFileSync('parser.js', parser.parse.toString());

const parse = parser.parse.bind(parser);
let indent = 0;
parser.parse = (input) => {
  const spaces = '  '.repeat(indent);
  indent++;
  console.log(`${spaces}---- parse start ${indent} -----`);

  console.log(input);

  const result = Array.prototype.concat.apply([], parse(input)).join('');

  console.log(`${spaces}---- parse end ${indent} -----`);
  indent--;

  return result.split('\n').map(line => spaces + line).join('\n');
};

let buffer = '';
rl.on('line', (input) => {
  buffer += input + ' ';
  if (input === '') {
    const result = parser.parse(buffer);
    console.log(result.split('\n').map(line => line.replace('        ', '')).join('\n'));
  }
});
