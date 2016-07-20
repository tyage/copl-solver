{
  // op =  '=' / '+' / '*'
  class Exp {
    constructor(op, e1, e2 = null) {
      this.op = op;
      this.e1 = e1;
      this.e2 = e2;

      switch (op) {
        case '=':
          this.n = e1;
          break;
        case '+':
          this.n = e1.n + e2.n;
          break;
        case '-':
          this.n = e1.n - e2.n;
          break;
        case '*':
          this.n = e1.n * e2.n;
          break;
      }
    }
    toString() {
      if (this.op === '=') {
        return this.e1.toString();
      }

      return `${this.e1} ${this.op} ${this.e2}`;
    }
  }
}

EvalML1
  = i1:Int _ 'evalto' _ i2:Int {
      // TODO: check if i1 === i2
      return `${text()} by E-Int {}`;
    }
  / b1:Bool _ 'evalto' _ b2:Bool {
      // TODO: check if b1 === b2
      return `${text()} by E-Bool {}`;
    }
  / e:Exp _ 'evalto' _ i:Int {
      switch (e.op) {
        case '+':
          return `${text()} by E-Plus {
  ${parser.parse(`${e.e1} evalto ${e.e1.n}`)};
  ${parser.parse(`${e.e2} evalto ${e.e2.n}`)};
  ${parser.parse(`${e.e1.n} plus ${e.e2.n} is ${i}`)};
}`;
          break;
        case '-':
          return `${text()} by E-Minus {
  ${parser.parse(`${e.e1} evalto ${e.e1.n}`)};
  ${parser.parse(`${e.e2} evalto ${e.e2.n}`)};
  ${parser.parse(`${e.e1.n} minus ${e.e2.n} is ${i}`)};
}`;
        case '*':
          return `${text()} by E-Times {
  ${parser.parse(`${e.e1} evalto ${e.e1.n}`)};
  ${parser.parse(`${e.e2} evalto ${e.e2.n}`)};
  ${parser.parse(`${e.e1.n} times ${e.e2.n} is ${i}`)};
}`;
          break;
      }
    }
  / i1:Int _ 'plus' _ i2:Int _ 'is' _ i3:Int {
      // TODO: check
      return `${text()} by B-Plus {}`;
    }
  / i1:Int _ 'minus' _ i2:Int _ 'is' _ i3:Int {
      // TODO: check
      return `${text()} by B-Minus {}`;
    }
  / i1:Int _ 'times' _ i2:Int _ 'is' _ i3:Int {
      // TODO: check
      return `${text()} by B-Times {}`;
    }

Exp
  = e1:ExpTimes tail:(_ ('+' / '-') _ ExpTimes)* {
      let result = e1;
      tail.forEach(e => {
        result = new Exp(e[1], result, e[3]);
      });
      return result;
    }
ExpTimes
  = e1:ExpPrimary tail:(_ '*' _ ExpPrimary)* {
      let result = e1;
      tail.forEach(e => {
        result = new Exp(e[1], result, e[3]);
      });
      return result;
    }
ExpPrimary
  = '(' _ exp:Exp _ ')' { return exp; }
  / i:Int { return new Exp('=', i); }

Int
  = [-]?[0-9]+ { return parseInt(text(), 10); }

Bool
  = 'true' { return true; }
  / 'false' { return false; }

_ 'whitespace'
  = [ \t\n\r]*
