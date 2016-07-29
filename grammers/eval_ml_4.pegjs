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
  class FunValue extends Value {
    constructor(env, fun) {
      super();

      this.env = env;
      this.fun = fun;
    }
    toString() {
      return `(${this.env})[${this.fun}]`;
    }
  }
  class RecFunValue extends Value {
    constructor(env, x, fun) {
      super();

      this.env = env;
      this.x = x;
      this.fun = fun;
    }
    toString() {
      return `(${this.env})[rec ${this.x} = ${this.fun}]`;
    }
  }
  class ArrayValue extends Value {
    constructor(value = null, arrayValue = null) {
      super();

      this.value = value;
      this.arrayValue = arrayValue;
    }
    toString() {
      if (this.arrayValue !== null && this.value !== null) {
        return `${this.value} :: ${this.arrayValue}`;
      } else {
        return `[]`;
      }
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
      // XXX: parserでやればevaluateいらなさそう...
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
        if (v1.type === 'Bool') {
          if (v1.value) {
            const v2 = e2.evaluate(env);
            if (v2.type === 'Int') {
              return v2;
            }
          } else {
            const v3 = e3.evaluate(env);
            if (v3.type === 'Int') {
              return v3;
            }
          }
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
          return `(${this.e1} ${this.op} ${this.e2})`;
      }
    }
  }
  class FunExp extends Exp {
    constructor(x, e) {
      super('fun');

      this.x = x;
      this.e = e;
    }
    toString() {
      return `fun ${this.x} -> ${this.e}`;
    }
    evaluate(env) {
      return new FunValue(env, this);
    }
  }
  class LetRecExp extends Exp {
    constructor(x, fun, e) {
      super('letRec');

      this.x = x;
      this.fun = fun;
      this.e = e;
    }
    toString() {
      return `let rec ${this.x} = ${this.fun} in ${this.e}`;
    }
    evaluate(env) {
      const funValue = this.fun.evaluate(env);
      const recFunValue = new RecFunValue(env, this.x, funValue);
      const env2 = new Env(env, this.x, recFunValue);
      return this.e.evaluate(env);
    }
  }
  class ApplyExp extends Exp {
    constructor(e1, e2) {
      super('apply');

      this.e1 = e1;
      this.e2 = e2;
    }
    toString() {
      const e2 = (this.e2 instanceof FunExp) ? `(${this.e2})` : this.e2.toString();
      return `(${this.e1} ${e2})`;
    }
    evaluate(env) {
      const funVal = this.e1.evaluate(env);
      let newEnv = funVal.env;
      if (funVal instanceof RecFunValue) {
        newEnv = new Env(newEnv, funVal.x, funVal)
      }
      newEnv = new Env(newEnv, funVal.fun.x, this.e2.evaluate(env));
      return funVal.fun.e.evaluate(newEnv);
    }
  }
  class ArrayExp extends Exp {
    constructor(e = null, arrayExp = null) {
      super('array');

      this.e = e;
      this.arrayExp = arrayExp;
    }
    toString() {
      if (this.arrayExp !== null && this.e !== null) {
        return `${this.e} :: ${this.arrayExp}`;
      } else {
        return `[]`;
      }
    }
    evaluate(env) {
      if (this.e !== null && this.arrayExp !== null) {
        return new ArrayValue(
          this.e.evaluate(env),
          this.arrayExp.evaluate(env)
        );
      } else {
        return new ArrayValue();
      }
    }
  }
  class MatchExp extends Exp {
    constructor(e1, e2, x, y, e3) {
      super('match');

      this.e1 = e1;
      this.e2 = e2;
      this.x = x;
      this.y = y;
      this.e3 = e3;
    }
    toString() {
      return `match ${this.e1} with [] -> ${this.e2} | ${this.x} :: ${this.y} -> ${this.e3}`;
    }
    evaluate(env) {
      const v1 = this.e1.evaluate(env);
      if (v1.value === null) {
        return this.e2.evaluate(env);
      } else {
        let newEnv = new Env(env, this.x, v1.value);
        newEnv = new Env(newEnv, this.y, v1.arrayValue);
        return this.e3.evaluate(newEnv);
      }
    }
  }
}

start
  = _ EvalML3 _

EvalML3
  = env:Env _ '|-' _ i1:Int _ 'evalto' _ i2:Int {
      // TODO: check if i1 === i2
      return `${text()} by E-Int {}`;
    }
  / env:Env _ '|-' _ b1:Bool _ 'evalto' _ b2:Bool {
      // TODO: check if b1 === b2
      return `${text()} by E-Bool {}`;
    }
  / env:Env _ '|-' _ b1:Bool _ 'evalto' _ b2:Bool {
      // TODO: check if b1 === b2
      return `${text()} by E-Bool {}`;
    }
  / env:Env _ '|-' _ x:Var _ 'evalto' _ v:Value {
      // TODO: check if env.resolve(x) === v
      return `${text()} by E-Var {}`;
    }
  / env:Env _ '|-' _ e:Fun _ 'evalto' _ v:FunValue {
      return `${text()} by E-Fun {}`;
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
      const evaluateApply = (e1, e2) => {
        const v1 = e.e1.evaluate(env);
        const v2 = e.e2.evaluate(env);
        if (v1 instanceof FunValue) {
          const e0 = v1.fun.e;
          const env2 = new Env(v1.env, v1.fun.x, v2);
          return `${text()} by E-App {
${parser.parse(`${env} |- ${e.e1} evalto ${v1}`)};
${parser.parse(`${env} |- ${e.e2} evalto ${v2}`)};
${parser.parse(`${env2} |- ${e0} evalto ${v}`)};
}`;
        } else if (v1 instanceof RecFunValue) {
          const e0 = v1.fun.e;
          let env2 = new Env(v1.env, v1.x, v1);
          env2 = new Env(env2, v1.fun.x, v2);
          return `${text()} by E-AppRec {
${parser.parse(`${env} |- ${e.e1} evalto ${v1}`)};
${parser.parse(`${env} |- ${e.e2} evalto ${v2}`)};
${parser.parse(`${env2} |- ${e0} evalto ${v}`)};
}`;
        } else {
          console.log(e);
          throw Error('v1 is not a function');
        }
      };
      const evaluateLetRec = (x, fun, e) => {
        const funValue = fun.evaluate(env);
        const recFunValue = new RecFunValue(env, x, fun);
        const env2 = new Env(env, x, recFunValue);

        return `${text()} by E-LetRec {
${parser.parse(`${env2} |- ${e} evalto ${v}`)};
}`;
      };
      const evaluateArray = (e, arrayExp) => {
        if (e !== null && arrayExp !== null) {
          const v1 = e.evaluate(env);
          const v2 = arrayExp.evaluate(env);
          return `${text()} by E-Cons {
${parser.parse(`${env} |- ${e} evalto ${v1}`)};
${parser.parse(`${env} |- ${arrayExp} evalto ${v2}`)};
}`;
        } else {
          return `${text()} by E-Nil {}`;
        }
      };
      const evaluateMatch = (e1, e2, x, y, e3) => {
        const v1 = e1.evaluate(env);
        if (v1.value === null) {
          return `${text()} by E-MatchNil {
${parser.parse(`${env} |- ${e1} evalto ${v1}`)};
${parser.parse(`${env} |- ${e2} evalto ${e2.evaluate(env)}`)};
}`;
        } else {
          let newEnv = new Env(env, x, v1.value);
          newEnv = new Env(newEnv, y, v1.arrayValue);
          return `${text()} by E-MatchCons {
${parser.parse(`${env} |- ${e1} evalto ${v1}`)};
${parser.parse(`${newEnv} |- ${e3} evalto ${e3.evaluate(newEnv)}`)};
}`;
        }
      };

      switch (e.op) {
        case '+':
        case '-':
        case '*':
        case '<':
          return evaluateOp(e.op, e.e1, e.e2);
        case 'if':
          return evaluateIf(e.e1, e.e2, e.e3);
        case 'let':
          return evaluateLet(e.e1, e.e2, e.e3);
        case 'apply':
          return evaluateApply(e.e1, e.e2);
        case 'letRec':
          return evaluateLetRec(e.x, e.fun, e.e);
        case 'array':
          return evaluateArray(e.e, e.arrayExp);
        case 'match':
          return evaluateMatch(e.e1, e.e2, e.x, e.y, e.e3);
      }

      throw Error(`op ${e.op} is not defined`);
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
  = e1:ExpArray tail:(_ '*' _ ExpArray)* {
      let result = e1;
      tail.forEach(e => {
        result = new Exp(e[1], result, e[3]);
      });
      return result;
    }
ExpArray
  = e1:ExpApply _ '::' _ e2:ExpArray {
      return new ArrayExp(e1, e2);
    }
  / '[]' { return new ArrayExp() }
  / ExpApply
ExpApply
  = Apply
  / ExpPrim
ExpPrim
  = '(' _ exp:Exp _ ')' { return exp; }
  / Fun
  / v:PrimValue { return new Exp('Value', v); }
  / v:Var { return new Exp('Var', v); }
  / 'if' _ e1:Exp _ 'then' _ e2:Exp _ 'else' _ e3:Exp {
      return new Exp('if', e1, e2, e3);
    }
  / 'let' _ v:Var _ '=' _ e1:Exp _ 'in' _ e2:Exp {
      return new Exp('let', v, e1, e2);
    }
  / 'let' _ 'rec' _ x:Var _ '=' _ fun:Fun _ 'in' _ e:Exp {
      return new LetRecExp(x, fun, e)
    }
  / 'match' _ e1:Exp _ 'with' _ '[]' _ '->' _ e2:Exp _ '|' _ x:Var _ '::' _ y:Var _ '->' _ e3:Exp {
      return new MatchExp(e1, e2, x, y, e3);
    }
Fun
  = 'fun' _ x:Var _ '->' _ e:Exp {
      return new FunExp(x, e);
    }
  / '(' _ f:Fun _ ')' { return f; }
Apply
  = v:Var _ arg0:ExpArray args:(_ ExpArray)* {
      let apply = new ApplyExp(new Exp('Var', v), arg0);
      args.forEach(arg => {
        apply = new ApplyExp(apply, arg[1]);
      });
      return apply;
    }
  / '(' _ a:Apply _ ')' { return a; }
  / '(' _ e1:Exp _ e2:Exp _ ')' { return new ApplyExp(e1, e2); }

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
  = ArrayValue
  / PrimValue
PrimValue
  = i:Int { return new Value('Int', i); }
  / b:Bool { return new Value('Bool', b); }
  / FunValue
  / RecFunValue
ArrayValue
  = value:PrimValue _ '::' _ arrayValue:ArrayValue {
      return new ArrayValue(value, arrayValue);
    }
  / '[]' { return new ArrayValue(); }
FunValue
  = '(' _ e:Env _ ')[' _ fun:Fun _ ']' { return new FunValue(e, fun); }
RecFunValue
  = '(' _ e:Env _ ')[' _ 'rec' _ x:Var _ '=' _ fun:Fun _ ']' { return new RecFunValue(e, x, fun); }

Var
  = !ReservedWord string:[A-Za-z_]+ { return string.join(''); }

ReservedWord
  = ( "let" / "rec" / "fun" / "evalto" / "if" / "else" / "then" / "in" / "match" / "with") ![A-Za-z_]

Bool
  = 'true' { return true; }
  / 'false' { return false; }

Int
  = [-]?[0-9]+ { return parseInt(text(), 10); }

_ 'whitespace'
  = [ \t\n\r]*
