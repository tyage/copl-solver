Int
  = [0-9]+ { return parseInt(text(), 10); }

Bool
  = 'true' { return true; }
  / 'false' { return false; }

_ 'whitespace'
  = [ \t\n\r]*
