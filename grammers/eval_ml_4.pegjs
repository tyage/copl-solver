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
      super('FunValue');

      this.env = env;
      this.fun = fun;
    }
    toString() {
      return `(${this.env})[${this.fun}]`;
    }
  }
  class RecFunValue extends Value {
    constructor(env, x, fun) {
      super('RecFunValue');

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
      super('ArrayValue');

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
  }
  class ApplyExp extends Exp {
    constructor(e1, e2) {
      super('apply');

      this.e1 = e1;
      this.e2 = e2;
    }
    toString() {
      const e2 = (this.e2.op === 'fun') ? `(${this.e2})` : this.e2.toString();
      return `(${this.e1} ${e2})`;
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
  }

  const parse = (text) => {
    const rule = parser.parse(text);
    return [parser.returnValue, rule];
  };
}

start
  = _ EvalML4 _

EvalML4
  = env:Env _ '|-' _ i:Int _ 'evalto' {
      const v = new Value('Int', i);
      parser.returnValue = v;
      return `${text()} ${i} by E-Int {};`;
    }
  / env:Env _ '|-' _ b:Bool _ 'evalto' {
      const v = new Value('Bool', b);
      parser.returnValue = v;
      return `${text()} ${v} by E-Bool {};`;
    }
  / env:Env _ '|-' _ x:Var _ 'evalto' {
      const v = env.resolve(x);
      parser.returnValue = v;
      return `${text()} ${v} by E-Var {};`;
    }
  / env:Env _ '|-' _ e:Fun _ 'evalto' {
      const v = new FunValue(env, e);
      parser.returnValue = v;
      return `${text()} ${v} by E-Fun {};`;
    }
  / env:Env _ '|-' _ e:Exp _ 'evalto' _ v:Value {
      return parser.parse(`${env} |- ${e} evalto`);
    }
  / env:Env _ '|-' _ e:Exp _ 'evalto' {
      const result = (v, rule, subRules = []) => {
        subRules = subRules.join('\n');
        parser.returnValue = v;
        return `${text()} ${v} by ${rule} {\n${subRules}\n};`;
      };
      const evaluateOp = (op, e1, e2) => {
        const [v1, e1Rule] = parse(`${env} |- ${e1} evalto`);
        const [v2, e2Rule] = parse(`${env} |- ${e2} evalto`);
        let v;
        switch (op) {
          case '+':
            v = new Value('Int', v1.value + v2.value);
            const plusRule = parser.parse(`${v1.value} plus ${v2.value} is ${v}`);
            return result(v, 'E-Plus', [e1Rule, e2Rule, plusRule]);
          case '-':
            v = new Value('Int', v1.value - v2.value);
            const minusRule = parser.parse(`${v1.value} minus ${v2.value} is ${v}`);
            return result(v, 'E-Minus', [e1Rule, e2Rule, minusRule]);
          case '*':
            v = new Value('Int', v1.value * v2.value);
            const timesRule = parser.parse(`${v1.value} times ${v2.value} is ${v}`);
            return result(v, 'E-Times', [e1Rule, e2Rule, timesRule]);
          case '<':
            v = new Value('Bool', v1.value < v2.value);
            const ltRule = parser.parse(`${v1.value} less than ${v2.value} is ${v}`);
            return result(v, 'E-Lt', [e1Rule, e2Rule, ltRule]);
        }

        return new Value('Error', 'error');
      };
      const evaluateIf = (e1, e2, e3) => {
        const [v1, e1Rule] = parse(`${env} |- ${e.e1} evalto`);
        if (v1.value) {
          const [v2, e2Rule] = parse(`${env} |- ${e.e2} evalto`);
          return result(v2, 'E-IfT', [e1Rule, e2Rule]);
        } else {
          const [v3, e3Rule] = parse(`${env} |- ${e.e3} evalto`);
          return result(v3, 'E-IfF', [e1Rule, e3Rule]);
        }
      };
      const evaluateLet = (variable, e1, e2) => {
        const [v1, e1Rule] = parse(`${env} |- ${e1} evalto`);
        const env2 = new Env(env, variable, v1);
        const [v2, e2Rule] = parse(`${env2} |- ${e2} evalto`);
        return result(v2, 'E-Let', [e1Rule, e2Rule]);
      };
      const evaluateApply = (e1, e2) => {
        const [v1, e1Rule] = parse(`${env} |- ${e.e1} evalto`);
        const [v2, e2Rule] = parse(`${env} |- ${e.e2} evalto`);

        if (v1.type === 'FunValue') {
          const e0 = v1.fun.e;
          const env2 = new Env(v1.env, v1.fun.x, v2);
          const [v, e0Rule] = parse(`${env2} |- ${e0} evalto`);
          return result(v, 'E-App', [e1Rule, e2Rule, e0Rule]);
        }

        if (v1.type === 'RecFunValue') {
          const e0 = v1.fun.e;
          let env2 = new Env(v1.env, v1.x, v1);
          env2 = new Env(env2, v1.fun.x, v2);
          const [v0, e0Rule] = parse(`${env2} |- ${e0} evalto`);
          return result(v0, 'E-AppRec', [e1Rule, e2Rule, e0Rule]);
        }

        console.log(e);
        throw Error('v1 is not a function');
      };
      const evaluateLetRec = (x, fun, e) => {
        const recFunValue = new RecFunValue(env, x, fun);
        const env2 = new Env(env, x, recFunValue);
        const [v, eRule] = parse(`${env2} |- ${e} evalto`);
        return result(v, 'E-LetRec', [eRule]);
      };
      const evaluateArray = (e, arrayExp) => {
        if (e !== null && arrayExp !== null) {
          const [v1, eRule] = parse(`${env} |- ${e} evalto`);
          const [v2, arrayExpRule] = parse(`${env} |- ${arrayExp} evalto`);
          return result(new ArrayValue(v1, v2), 'E-Cons', [eRule, arrayExpRule]);
        } else {
          return result(new ArrayValue(), 'E-Nil');
        }
      };
      const evaluateMatch = (e1, e2, x, y, e3) => {
        const [v1, e1Rule] = parse(`${env} |- ${e1} evalto`);
        if (v1.value === null) {
          const [v2, e2Rule] = parse(`${env} |- ${e2} evalto`);
          return result(v2, 'E-MatchNil', [e1Rule, e2Rule]);
        } else {
          let newEnv = new Env(env, x, v1.value);
          newEnv = new Env(newEnv, y, v1.arrayValue);
          const [v3, e3Rule] = parse(`${newEnv} |- ${e3} evalto`);
          return result(v3, 'E-MatchCons', [e1Rule, e3Rule]);
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
      return `${text()} by B-Plus {};`;
    }
  / i1:Int _ 'minus' _ i2:Int _ 'is' _ i3:Int {
      // TODO: check
      return `${text()} by B-Minus {};`;
    }
  / i1:Int _ 'times' _ i2:Int _ 'is' _ i3:Int {
      // TODO: check
      return `${text()} by B-Times {};`;
    }
  / i1:Int _ 'less' _ 'than' _ i2:Int _ 'is' _ b3:Bool {
      // TODO: check
      return `${text()} by B-Lt {};`;
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
