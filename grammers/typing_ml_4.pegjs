{
  class Env {
    constructor(env = null, variable = null, type = null) {
      this.env = env;
      this.variable = variable;
      this.type = type;

      this.map = new Map(env && env.map);
      this.map.set(this.variable, this.type);
    }
    toString() {
      const bind = this.variable === null ? '' : `${this.variable} : ${this.type}`;

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
    constructor() {}
    createRule(env, type, rule, rules = []) {
      return `${env} |- ${this.toString()} : ${type} by ${rule} {\n${rules.join('\n')}\n};`;
    }
  }
  class LetExp extends Exp {
    constructor(v, e1, e2) {
      super();

      this.v = v;
      this.e1 = e1;
      this.e2 = e2;
    }
    toString() {
      return `let ${this.v} = ${this.e1} in ${this.e2}`;
    }
    resolveType(env) {
      const [e1Type, e1Rule] = this.e1.resolveType(env);
      const env2 = new Env(env, this.v, e1Type);
      const [e2Type, e2Rule] = this.e2.resolveType(env2);
      return [e2Type, this.createRule(env, e2Type, 'T-Let', [e1Rule, e2Rule])];
    }
  }
  class VarExp extends Exp {
    constructor(x) {
      super();

      this.x = x;
    }
    toString() {
      return this.x.toString();
    }
    resolveType(env) {
      const xType = env.resolve(this.x);
      return [xType, this.createRule(env, xType, 'T-Var')];
    }
  }
  class IfExp extends Exp {
    constructor(e1, e2, e3) {
      super();

      this.e1 = e1;
      this.e2 = e2;
      this.e3 = e3;
    }
    toString() {
      return `if ${this.e1} then ${this.e2} else ${this.e3}`;
    }
    resolveType(env) {
      const [e1Type, e1Rule] = this.e1.resolveType(env);
      const [e2Type, e2Rule] = this.e2.resolveType(env);
      const [e3Type, e3Rule] = this.e3.resolveType(env);

      if (e1Type !== 'bool' || e2Type !== e3Type) {
        throw new Error(`type of IfExp does not match: ${e1Type} !== 'bool' or ${e2Type} !== ${e3Type}`);
      }

      return [e2Type, this.createRule(env, e2Type, 'T-If', [e1Rule, e2Rule, e3Rule])];
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

      let opType = null;
      let rule = null;
      switch (this.op) {
        case '-':
          rule = 'T-Minus';
          opType = 'int';
          break;
        case '+':
          rule = 'T-Plus';
          opType = 'int';
          break;
        case '*':
          rule = 'T-Times';
          opType = 'int';
          break;
        case '<':
          rule = 'T-Lt';
          opType = 'bool';
          break;
      }

      return [opType, this.createRule(env, opType, rule, [e1Rule, e2Rule])];
    }
  }
  class FunExp extends Exp {
    constructor(x, e) {
      super();

      this.x = x;
      this.e = e;
    }
    toString() {
      return `(fun ${this.x} -> ${this.e})`;
    }
    resolveType(env) {
      const newEnv = new Env(env, this.x, new UndefinedType());
      const [eType, eRule] = this.e.resolveType(newEnv);
      const type = new FunType(typeHint.t1, eType);
      return [type, this.createRule(env, type, 'T-Fun', [eRule])];
    }
  }
  class LetRecExp extends Exp {
    constructor(x, fun, e) {
      super();

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
      super();

      this.e1 = e1;
      this.e2 = e2;
    }
    toString() {
      const e2 = (this.e2 instanceof FunExp) ? `(${this.e2})` : this.e2.toString();
      return `(${this.e1} ${e2})`;
    }
    resolveType(env) {
      const [e2Type, e2Rule] = this.e2.resolveType(env);
      const [e1Type, e1Rule] = this.e1.resolveType(env, new FunType(e2Type, null));

      if (e1Type.t1 !== e2Type) {
        throw new Error(`type of ApplyExp does not match: ${e1Type.t1} !== ${e2Type}`);
      }

      return [e1Type.t2, this.createRule(env, e1Type.t2, 'T-App', [e1Rule, e2Rule])];
    }
  }
  class ArrayExp extends Exp {
    constructor(e = null, arrayExp = null) {
      super();

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
      super();

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

  class Type {}
  class FunType extends Type {
    constructor(t1, t2) {
      super();
      this.t1 = t1;
      this.t2 = t2;
    }
    toString() {
      return `${this.t1} -> ${this.t2}`;
    }
  }
}

start
  = _ EvalML4 _

EvalML4
  = env:Env _ '|-' _ e:Exp _ ':' _ type:Types {
      console.log(e);
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
  = v:Var _ arg0:ExpArray args:(_ ExpArray)* {
      let apply = new ApplyExp(new VarExp(v), arg0);
      args.forEach(arg => {
        apply = new ApplyExp(apply, arg[1]);
      });
      return apply;
    }
  / ExpPrim
ExpPrim
  = '(' _ exp:Exp _ ')' { return exp; }
  / Fun
  / i:Int { return new IntExp(i); }
  / b:Bool { return new BoolExp(b); }
  / v:Var { return new VarExp(v); }
  / 'if' _ e1:Exp _ 'then' _ e2:Exp _ 'else' _ e3:Exp {
      return new IfExp(e1, e2, e3);
    }
  / 'let' _ v:Var _ '=' _ e1:Exp _ 'in' _ e2:Exp {
      return new LetExp(v, e1, e2);
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
        fun = new FunExp(arg[1], fun);
      });
      return fun;
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
  = type:PrimTypes types:(_ '->' _ PrimTypes)+ {
      let typeList = null;
      types.reverse().forEach(t => {
        if (typeList === null) {
          typeList = t[3];
        } else {
          typeList = new FunType(t[3], typeList);
        }
      });
      return new FunType(type, typeList);
    }
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
