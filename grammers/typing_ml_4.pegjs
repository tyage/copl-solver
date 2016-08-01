{
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
      }
    }
    resolveType() {

    }
    createRule(env, type, rule, rules = []) {
      return `${env} |- ${this.toString()} : ${type} by ${rule} {\n${rules.join('\n')}\n};`;
    }
  }
  class IntExp extends Exp {
    constructor(value) {
      super();
      this.value = value;
    }
    toString() {
      return this.value;
    }
    resolveType(env) {
      return ['int', this.createRule(env, 'int', 'T-Int')];
    }
  }
  class BoolExp extends Exp {
    constructor(value) {
      super();
      this.value = value;
    }
    toString() {
      return this.value;
    }
    resolveType(env) {
      return ['bool', this.createRule(env, 'bool', 'T-Bool')];
    }
  }
  // op =  '-' / '+' / '*' / '<'
  class OpExp extends Exp {
    constructor(op, e1, e2) {
      super();

      this.op = op;
      this.e1 = e1;
      this.e2 = e2;
    }
    toString() {
      return `(${this.e1} ${this.op} ${this.e2})`;
    }
    resolveType(env) {
      const [e1Type, e1Rule] = this.e1.resolveType(env);
      const [e2Type, e2Rule] = this.e2.resolveType(env);

      let type = null;
      let rule = null;
      switch (this.op) {
        case '-':
          rule = 'T-Minus';
          type = 'int';
          break;
        case '+':
          rule = 'T-Plus';
          type = 'int';
          break;
        case '*':
          rule = 'T-Times';
          type = 'int';
          break;
        case '<':
          rule = 'T-Lt';
          type = 'bool';
          break;
      }

      return [type, this.createRule(env, type, rule, [e1Rule, e2Rule])];
    }
  }
  class FunExp extends Exp {
    constructor(x, e) {
      super('fun');

      this.x = x;
      this.e = e;
    }
    toString() {
      return `(fun ${this.x} -> ${this.e})`;
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
        return `(${this.e} :: ${this.arrayExp})`;
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
  = env:Env _ '|-' _ e:Exp _ ':' _ type:Types {
      return e.resolveType(env)[1];
    }

Exp
  = ExpComp
ExpComp
  = e1:ExpPlus _ '<' _ e2:ExpPlus {
      return new OpExp('<', e1, e2);
    }
  / ExpPlus
ExpPlus
  = e1:ExpTimes tail:(_ ('+' / '-') _ ExpTimes)* {
      let result = e1;
      tail.forEach(e => {
        result = new OpExp(e[1], result, e[3]);
      });
      return result;
    }
ExpTimes
  = e1:ExpArray tail:(_ '*' _ ExpArray)* {
      let result = e1;
      tail.forEach(e => {
        result = new OpExp(e[1], result, e[3]);
      });
      return result;
    }
ExpArray
  = e1:ExpApply tail:(_ '::' _ ExpArray)+ {
      let result = e1;
      tail.forEach(e => {
        result = new ArrayExp(result, e[3]);
      });
      return result;
    }
  / '[]' { return new ArrayExp() }
  / ExpApply
ExpApply
  = Apply
  / ExpPrim
ExpPrim
  = '(' _ exp:Exp _ ')' { return exp; }
  / Fun
  / i:Int { return new IntExp(i); }
  / b:Bool { return new BoolExp(b); }
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
  = 'fun' args:(_ Var _ '->')+ _ e:Exp {
      let fun = e;
      args.forEach(arg => {
        fun = new ApplyExp(arg[1], fun);
      });
      return fun;
    }
Apply
  = v:Var _ arg0:ExpArray args:(_ ExpArray)* {
      let apply = new ApplyExp(new Exp('Var', v), arg0);
      args.forEach(arg => {
        apply = new ApplyExp(apply, arg[1]);
      });
      return apply;
    }

Env
  = bind:(Var _ ':' _ Types) binds:(',' _ Var _ ':' _ Types)* {
      let env = new Env(null, bind[0], bind[4]);
      binds.forEach(bind => {
        env = new Env(env, bind[2], bind[6]);
      });
      return env;
    }
  / '' { return new Env(); }

Types
  = type:FunTypes _ 'list'
  / FunTypes
FunTypes
  = type:PrimTypes types:(_ '->' _ PrimTypes)+
  / PrimTypes
PrimTypes
  = 'bool'
  / 'int'

Var
  = !ReservedWord string:[A-Za-z0-9_]+ { return string.join(''); }

ReservedWord
  = ( "let" / "rec" / "fun" / "evalto" / "if" / "else" / "then" / "in" / "match" / "with" / "bool" / "int" / "list") ![A-Za-z0-9_]

Bool
  = 'true' { return true; }
  / 'false' { return false; }

Int
  = [-]?[0-9]+ { return parseInt(text(), 10); }

_ 'whitespace'
  = [ \t\n\r]*
