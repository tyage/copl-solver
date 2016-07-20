{
  class Nat {
    constructor(n) {
      this.n = n;
    }
    toString() {
      let str = 'Z';
      for (let i = 0; i < this.n; ++i) {
        str = `S(${str})`;
      }
      return str;
    }
    increment() {
      return new Nat(this.n + 1);
    }
    decrement() {
      return new Nat(this.n - 1);
    }
    plus(nat) {
      return new Nat(this.n + nat.n);
    }
    multiply(nat) {
      return new Nat(this.n * nat.n);
    }
  }

  // op =  '=' / '+' / '*'
  class Exp {
    constructor(op, e1, e2 = null) {
      this.op = op;
      this.e1 = e1;
      this.e2 = e2;

      switch (op) {
        case '=':
          this.nat = e1;
          break;
        case '+':
          this.nat = e1.nat.plus(e2.nat);
          break;
        case '*':
          this.nat = e1.nat.multiply(e2.nat);
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

start
  = Derivation
  / CompareNat1
  / EvalNatExp

Derivation
  = Zero _ 'plus' _ n1:Nat _ 'is' _ n2:Nat {
      // TODO: check if n1 is equal to n2
      return `${text()} by P-Zero {}`;
    }
  / Sn1:Nat _ 'plus' _ n2:Nat _ 'is' _ Sn:Nat {
      const n1 = Sn1.decrement();
      const n = Sn.decrement();
      return `${Sn1} plus ${n2} is ${Sn} by P-Succ {
  ${parser.parse(`${n1} plus ${n2} is ${n}`)}
}`;
    }
  / Zero _ 'times' _ n:Nat _ 'is' _ Zero {
      return `${text()} by T-Zero {}`;
    }
  / Sn1:Nat _ 'times' _ n2:Nat _ 'is' _ n4:Nat {
      const n1 = Sn1.decrement();
      const n3 = n1.multiply(n2);
      return `${text()} by T-Succ {
  ${parser.parse(`${n1} times ${n2} is ${n3}`)};
  ${parser.parse(`${n2} plus ${n3} is ${n4}`)};
}`;
    }

CompareNat1
  = n1:Nat _ 'is' _ 'less' _ 'than' _ n3:Nat {
      if (n1.n + 1 === n3.n) {
        return `${text()} by L-Succ {}`;
      }

      const n2 = n1.increment();
      return `${text()} by L-Trans {
  ${parser.parse(`${n1} is less than ${n2}`)};
  ${parser.parse(`${n2} is less than ${n3}`)};
}`;
    }

// TODO: CompareNat2, CompareNat3

EvalNatExp
  = n1:Nat _ 'evalto' _ n2:Nat {
      // TODO: check if n1 is equal to n2
      return `${text()} by E-Const {}`;
    }
  / e:Exp _ 'evalto' _ n:Nat {
      const e1 = e.e1;
      const e2 = e.e2;
      const n1 = e1.nat;
      const n2 = e2.nat;
      switch (e.op) {
        case '+':
          return `${text()} by E-Plus {
  ${parser.parse(`${e1} evalto ${n1}`)};
  ${parser.parse(`${e2} evalto ${n2}`)};
  ${parser.parse(`${n1} plus ${n2} is ${n}`)};
}`;
          break;
        case '*':
          return `${text()} by E-Times {
  ${parser.parse(`${e1} evalto ${n1}`)};
  ${parser.parse(`${e2} evalto ${n2}`)};
  ${parser.parse(`${n1} times ${n2} is ${n}`)};
}`;
      }
    }

Nat
  = 'S(' _ nat:Nat _ ')' { return nat.increment(); }
  / Zero

Zero
  = 'Z' { return new Nat(0); }

Exp
  = e1:ExpMult tail:(_ '+' _ ExpMult)* {
      let result = e1;
      tail.forEach(e => {
        result = new Exp('+', result, e[3]);
      });
      return result;
    }
ExpMult
  = e1:ExpPrimary tail:(_ '*' _ ExpPrimary)* {
      let result = e1;
      tail.forEach(e => {
        result = new Exp('*', result, e[3]);
      });
      return result;
    }
ExpPrimary
  = '(' _ exp:Exp _ ')' { return exp; }
  / n:Nat { return new Exp('=', n); }

_ 'whitespace'
  = [ \t\n\r]*
