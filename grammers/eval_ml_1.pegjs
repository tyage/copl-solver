{
  // op =  '=' / '+' / '*'
  class Exp {
    constructor(op, e1, e2 = null, e3 = null) {
      this.op = op;
      this.e1 = e1;
      this.e2 = e2;
      this.e3 = e3;

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
        case '<':
          this.bool = (e1.n < e2.n);
          break;
        case 'if':
          this.n = e1.bool ? e2.n : e3.n;
          break;
      }
    }
    toString() {
      if (this.op === '=') {
        return this.e1.toString();
      }
      if (this.op === 'if') {
        return `if ${this.e1} then ${this.e2} else ${this.e3}`;
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
  / e:Exp _ 'evalto' _ i:Value {
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
          break;
        case '*':
          return `${text()} by E-Times {
  ${parser.parse(`${e.e1} evalto ${e.e1.n}`)};
  ${parser.parse(`${e.e2} evalto ${e.e2.n}`)};
  ${parser.parse(`${e.e1.n} times ${e.e2.n} is ${i}`)};
}`;
          break;
        case '<':
          return `${text()} by E-Lt {
  ${parser.parse(`${e.e1} evalto ${e.e1.n}`)};
  ${parser.parse(`${e.e2} evalto ${e.e2.n}`)};
  ${parser.parse(`${e.e1.n} less than ${e.e2.n} is ${e.bool}`)};
}`;
          break;
        case 'if':
          if (e.e1.bool) {
            return `${text()} by E-IfT {
      ${parser.parse(`${e.e1} evalto true`)};
      ${parser.parse(`${e.e2} evalto ${i}`)};
    }`;
          } else {
            return `${text()} by E-IfF {
      ${parser.parse(`${e.e1} evalto false`)};
      ${parser.parse(`${e.e3} evalto ${i}`)};
    }`;
          }
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
  / i1:Int _ 'less' _ 'than' _ i2:Int _ 'is' _ b3:Bool {
      // TODO: check
      return `${text()} by B-Lt {}`;
    }

Value
  = Int
  / Bool

Exp
  = ExpComp
ExpComp
  = e1:ExpPlus _ '<' _ e2:ExpPlus {
      return new Exp('<', e1, e2);
    }
  / ExpPlus
ExpPlus
  = e1:ExpTimes tail:(_ ('+' / '-') _ ExpTimes)* {
      let result = e1;
      tail.forEach(e => {
        result = new Exp(e[1], result, e[3]);
      });
      return result;
    }
ExpTimes
  = e1:ExpIf tail:(_ '*' _ ExpIf)* {
      let result = e1;
      tail.forEach(e => {
        result = new Exp(e[1], result, e[3]);
      });
      return result;
    }
ExpIf
  = 'if' _ e1:Exp _ 'then' _ e2:Exp _ 'else' _ e3:Exp {
      return new Exp('if', e1, e2, e3);
    }
  / ExpPrimary
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
