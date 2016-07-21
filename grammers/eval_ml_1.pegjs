{
  // op =  '=' / '+' / '*'
  class Exp {
    constructor(op, e1, e2 = null, e3 = null) {
      this.op = op;
      this.e1 = e1;
      this.e2 = e2;
      this.e3 = e3;

      switch (op) {
        case 'Int':
        case 'Bool':
        case 'Error':
          this.v = e1;
          this.type = op;
          break;
        case '+':
          if (e1.type === 'Int' && e2.type === 'Int') {
            this.v = e1.v + e2.v;
            this.type = 'Int';
          }
          break;
        case '-':
          if (e1.type === 'Int' && e2.type === 'Int') {
            this.v = e1.v - e2.v;
            this.type = 'Int';
          }
          break;
        case '*':
          if (e1.type === 'Int' && e2.type === 'Int') {
            this.v = e1.v * e2.v;
            this.type = 'Int';
          }
          break;
        case '<':
          if (e1.type === 'Int' && e2.type === 'Int') {
            this.v = (e1.v < e2.v);
            this.type = 'Bool';
          }
          break;
        case 'if':
          if (e1.type === 'Bool' && e2.type === 'Int' && e3.type === 'Int') {
            this.v = e1.v ? e2.v : e3.v;
            this.type = e1.v ? e2.type : e3.type;
          }
          break;
      }

      if (this.type === undefined) {
        this.v = 'error';
        this.type = 'Error';
      }
    }
    toString() {
      switch (this.op) {
        case 'Int':
        case 'Bool':
        case 'Error':
          return this.e1.toString();
          break;
        case 'if':
          return `if ${this.e1} then ${this.e2} else ${this.e3}`;
          break;
        default:
          return `${this.e1} ${this.op} ${this.e2}`;
          break;
      }
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
  / e:Exp _ 'evalto' _ i:Res {
      switch (e.op) {
        case '+':
          if (e.e1.type === 'Error') {
            return `${text()} by E-PlusErrorL {
  ${parser.parse(`${e.e1} evalto ${e.e1.v}`)}
}`;
          }
          if (e.e2.type === 'Error') {
            return `${text()} by E-PlusErrorR {
  ${parser.parse(`${e.e2} evalto ${e.e2.v}`)}
}`;
          }
          if (e.e1.type === 'Bool') {
            return `${text()} by E-PlusBoolL {
  ${parser.parse(`${e.e1} evalto ${e.e1.v}`)}
}`;
          }
          if (e.e2.type === 'Bool') {
            return `${text()} by E-PlusBoolR {
  ${parser.parse(`${e.e2} evalto ${e.e2.v}`)}
}`;
          }
          return `${text()} by E-Plus {
  ${parser.parse(`${e.e1} evalto ${e.e1.v}`)};
  ${parser.parse(`${e.e2} evalto ${e.e2.v}`)};
  ${parser.parse(`${e.e1.v} plus ${e.e2.v} is ${i}`)};
}`;
          break;
        case '-':
          if (e.e1.type === 'Error') {
            return `${text()} by E-MinusErrorL {
  ${parser.parse(`${e.e1} evalto ${e.e1.v}`)}
}`;
          }
          if (e.e2.type === 'Error') {
            return `${text()} by E-MinusErrorR {
  ${parser.parse(`${e.e2} evalto ${e.e2.v}`)}
}`;
          }
          if (e.e1.type === 'Bool') {
            return `${text()} by E-MinusBoolL {
  ${parser.parse(`${e.e1} evalto ${e.e1.v}`)}
}`;
          }
          if (e.e2.type === 'Bool') {
            return `${text()} by E-MinusBoolR {
  ${parser.parse(`${e.e2} evalto ${e.e2.v}`)}
}`;
          }
          return `${text()} by E-Minus {
  ${parser.parse(`${e.e1} evalto ${e.e1.v}`)};
  ${parser.parse(`${e.e2} evalto ${e.e2.v}`)};
  ${parser.parse(`${e.e1.v} minus ${e.e2.v} is ${i}`)};
}`;
          break;
        case '*':
          if (e.e1.type === 'Error') {
            return `${text()} by E-TimesErrorL {
  ${parser.parse(`${e.e1} evalto ${e.e1.v}`)}
}`;
          }
          if (e.e2.type === 'Error') {
            return `${text()} by E-TimesErrorR {
  ${parser.parse(`${e.e2} evalto ${e.e2.v}`)}
}`;
          }
          if (e.e1.type === 'Bool') {
            return `${text()} by E-TimesBoolL {
  ${parser.parse(`${e.e1} evalto ${e.e1.v}`)}
}`;
          }
          if (e.e2.type === 'Bool') {
            return `${text()} by E-TimesBoolR {
  ${parser.parse(`${e.e2} evalto ${e.e2.v}`)}
}`;
          }
          return `${text()} by E-Times {
  ${parser.parse(`${e.e1} evalto ${e.e1.v}`)};
  ${parser.parse(`${e.e2} evalto ${e.e2.v}`)};
  ${parser.parse(`${e.e1.v} times ${e.e2.v} is ${i}`)};
}`;
          break;
        case '<':
          if (e.e1.type === 'Error') {
            return `${text()} by E-LtErrorL {
  ${parser.parse(`${e.e1} evalto ${e.e1.v}`)}
}`;
          }
          if (e.e2.type === 'Error') {
            return `${text()} by E-LtErrorR {
  ${parser.parse(`${e.e2} evalto ${e.e2.v}`)}
}`;
          }
          if (e.e1.type === 'Bool') {
            return `${text()} by E-LtBoolL {
  ${parser.parse(`${e.e1} evalto ${e.e1.v}`)}
}`;
          }
          if (e.e2.type === 'Bool') {
            return `${text()} by E-LtBoolR {
  ${parser.parse(`${e.e2} evalto ${e.e2.v}`)}
}`;
          }
          return `${text()} by E-Lt {
  ${parser.parse(`${e.e1} evalto ${e.e1.v}`)};
  ${parser.parse(`${e.e2} evalto ${e.e2.v}`)};
  ${parser.parse(`${e.e1.v} less than ${e.e2.v} is ${e.v}`)};
}`;
          break;
        case 'if':
          if (e.e1.type === 'Int') {
            return `${text()} by E-IfInt {
  ${parser.parse(`${e.e1} evalto ${e.e1.v}`)}
}`;
          }
          if (e.e1.type === 'Error') {
            return `${text()} by E-IfError {
  ${parser.parse(`${e.e1} evalto ${e.e1.v}`)}
}`;
          }
          if (e.e1.v && e.e2.type === 'Error') {
            return `${text()} by E-IfTError {
  ${parser.parse(`${e.e1} evalto true`)};
  ${parser.parse(`${e.e2} evalto ${e.e2.v}`)}
}`;
          }
          if (!e.e1.v && e.e3.type === 'Error') {
            return `${text()} by E-IfFError {
  ${parser.parse(`${e.e1} evalto false`)};
  ${parser.parse(`${e.e3} evalto ${e.e3.v}`)}
}`;
          }
          if (e.e1.v) {
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
  / i:Int { return new Exp('Int', i); }
  / b:Bool { return new Exp('Bool', b); }
  / e:Error { return new Exp('Error', e); }

Res
  = Value
  / Error

Value
  = Int
  / Bool

Error = 'error'

Int
  = [-]?[0-9]+ { return parseInt(text(), 10); }

Bool
  = 'true' { return true; }
  / 'false' { return false; }

_ 'whitespace'
  = [ \t\n\r]*
