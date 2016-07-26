{
  class Value {
    constructor(type, value) {
      this.type = type;
      this.value = value;
    }
    toString() {
      return this.value;
    }
  }
  class Env {
    constructor(env = null, variable = null, value = null) {
      this.env = env;
      this.variable = variable;
      this.value = value;

      this.map = new Map(env && env.map);
      this.map.set(this.variable, this.value);
    }
    toString() {
      const bind = this.variable === null ? '' : `${this.variable} = ${this.value}`;

      if (this.env === null || this.env.toString() === '') {
        return bind;
      }

      return `${this.env}, ${bind}`;
    }
    resolve(variable) {
      return this.map.get(variable);
    }
  }
  // op =  '=' / '+' / '*'
  class Exp {
    constructor(op, e1, e2 = null, e3 = null) {
      this.op = op;
      this.e1 = e1;
      this.e2 = e2;
      this.e3 = e3;
    }
    evaluate(env) {
      const evaluateOp = (op, e1, e2) => {
        const v1 = e1.evaluate(env);
        const v2 = e2.evaluate(env);
        switch (op) {
          case '+':
            if (v1.type === 'Int' && v2.type === 'Int') {
              return new Value('Int', v1.value + v2.value);
            }
            break;
          case '-':
            if (v1.type === 'Int' && v2.type === 'Int') {
              return new Value('Int', v1.value - v2.value);
            }
            break;
          case '*':
            if (v1.type === 'Int' && v2.type === 'Int') {
              return new Value('Int', v1.value * v2.value);
            }
            break;
          case '<':
            if (v1.type === 'Int' && v2.type === 'Int') {
              return new Value('Bool', v1.value < v2.value);
            }
            break;
        }

        return new Value('Error', 'error');
      };
      const evaluateIf = (e1, e2, e3) => {
        const v1 = e1.evaluate(env);
        const v2 = e2.evaluate(env);
        const v3 = e3.evaluate(env);
        if (v1.type === 'Bool' && v2.type === 'Int' && v3.type === 'Int') {
          return v1.value ? v2 : v3;
        }
      };
      const evaluateLet = (v, e1, e2) => {
        const v1 = e1.evaluate(env);
        const env2 = new Env(env, v, v1);
        return e2.evaluate(env2);
      };

      switch (this.op) {
        case 'Var':
          return env.resolve(this.e1);
        case 'Value':
          return this.e1;
        case '+':
        case '-':
        case '*':
        case '<':
          return evaluateOp(this.op, this.e1, this.e2);
        case 'if':
          return evaluateIf(this.e1, this.e2, this.e3);
        case 'let':
          return evaluateLet(this.e1, this.e2, this.e3);
      }

      return new Value('Error', 'error');
    }
    toString() {
      switch (this.op) {
        case 'Var':
        case 'Value':
          return this.e1.toString();
        case 'if':
          return `if ${this.e1} then ${this.e2} else ${this.e3}`;
        case 'let':
          return `let ${this.e1} = ${this.e2} in ${this.e3}`;
        default:
          return `${this.e1} ${this.op} ${this.e2}`;
      }
    }
  }
}

EvalML3
  = env:Env _ '|-' _ i1:Int _ 'evalto' _ i2:Int {
      // TODO: check if i1 === i2
      return `${text()} by E-Int {}`;
    }
  / env:Env _ '|-' _ b1:Bool _ 'evalto' _ b2:Bool {
      // TODO: check if b1 === b2
      return `${text()} by E-Bool {}`;
    }
  / env:Env _ '|-' _ x:Var _ 'evalto' _ v:Value {
      // TODO: check if x === v
      if (env.variable === x) {
        return `${text()} by E-Var1 {}`;
      } else {
        return `${text()} by E-Var2 {
  ${parser.parse(`${env.env} |- ${x} evalto ${v}`)}
}`;
      }
    }
  / env:Env _ '|-' _ e:Exp _ 'evalto' _ v:Value {
      const evaluateOp = (op, e1, e2) => {
        const v1 = e1.evaluate(env);
        const v2 = e2.evaluate(env);
        switch (op) {
          case '+':
            return `${text()} by E-Plus {
  ${parser.parse(`${env} |- ${e1} evalto ${v1.value}`)};
  ${parser.parse(`${env} |- ${e2} evalto ${v2.value}`)};
  ${parser.parse(`${v1.value} plus ${v2.value} is ${v}`)};
}`;
          case '-':
            return `${text()} by E-Minus {
  ${parser.parse(`${env} |- ${e1} evalto ${v1.value}`)};
  ${parser.parse(`${env} |- ${e2} evalto ${v2.value}`)};
  ${parser.parse(`${v1.value} minus ${v2.value} is ${v}`)};
}`;
          case '*':
            return `${text()} by E-Times {
  ${parser.parse(`${env} |- ${e1} evalto ${v1.value}`)};
  ${parser.parse(`${env} |- ${e2} evalto ${v2.value}`)};
  ${parser.parse(`${v1.value} times ${v2.value} is ${v}`)};
}`;
          case '<':
            return `${text()} by E-Lt {
  ${parser.parse(`${env} |- ${e1} evalto ${v1.value}`)};
  ${parser.parse(`${env} |- ${e2} evalto ${v2.value}`)};
  ${parser.parse(`${v1.value} less than ${v2.value} is ${v}`)};
}`;
        }

        return new Value('Error', 'error');
      };
      const evaluateIf = (e1, e2, e3) => {
        const v1 = e1.evaluate(env);
        const v2 = e2.evaluate(env);
        const v3 = e3.evaluate(env);
        if (v1.value) {
          return `${text()} by E-IfT {
${parser.parse(`${env} |- ${e.e1} evalto true`)};
${parser.parse(`${env} |- ${e.e2} evalto ${v}`)};
}`;
        } else {
          return `${text()} by E-IfF {
${parser.parse(`${env} |- ${e.e1} evalto false`)};
${parser.parse(`${env} |- ${e.e3} evalto ${v}`)};
}`;
        }
      };
      const evaluateLet = (variable, e1, e2) => {
        const v1 = e1.evaluate(env);
        const env2 = new Env(env, variable, v1);
        return `${text()} by E-Let {
  ${parser.parse(`${env} |- ${e1} evalto ${v1}`)};
  ${parser.parse(`${env2} |- ${e2} evalto ${v}`)};
}`;
      };

      switch (e.op) {
        case '+':
        case '-':
        case '*':
        case '<':
          return evaluateOp(e.op, e.e1, e.e2);
          break;
        case 'if':
          return evaluateIf(e.e1, e.e2, e.e3);
          break;
        case 'let':
          return evaluateLet(e.e1, e.e2, e.e3);
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
  = e1:ExpPrim tail:(_ '*' _ ExpPrim)* {
      let result = e1;
      tail.forEach(e => {
        result = new Exp(e[1], result, e[3]);
      });
      return result;
    }
ExpPrim
  = '(' _ exp:Exp _ ')' { return exp; }
  / v:Value { return new Exp('Value', v); }
  / v:Var { return new Exp('Var', v); }
  / 'if' _ e1:Exp _ 'then' _ e2:Exp _ 'else' _ e3:Exp {
      return new Exp('if', e1, e2, e3);
    }
  / 'let' _ v:Var _ '=' _ e1:Exp _ 'in' _ e2:Exp {
      return new Exp('let', v, e1, e2);
    }

Env
  = bind:(Var _ '=' _ Value) binds:(',' _ Var _ '=' _ Value)* {
      let env = new Env(null, bind[0], bind[4]);

      binds.forEach(bind => {
        env = new Env(env, bind[2], bind[6]);
      });

      return env;
    }
  / '' { return new Env(); }

Value
  = i:Int { return new Value('Int', i); }
  / b:Bool { return new Value('Bool', b); }

Var
  = 'x' / 'y'

Bool
  = 'true' { return true; }
  / 'false' { return false; }

Int
  = [-]?[0-9]+ { return parseInt(text(), 10); }

_ 'whitespace'
  = [ \t\n\r]*
