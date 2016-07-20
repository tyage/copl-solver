// TODO: 導出システムごとに分けるべき

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
    times(nat) {
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
          this.nat = e1.nat.times(e2.nat);
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
  = NatExp
  / CompareNat1
  / EvalNatExp
  / ReduceNatExp

NatExp
  = Zero _ 'plus' _ n1:Nat _ 'is' _ n2:Nat {
      // TODO: check if n1 is equal to n2
      return `${text()} by P-Zero {}`;
    }
  / Sn1:Nat _ 'plus' _ n2:Nat _ 'is' _ Sn:Nat {
      const n1 = Sn1.decrement();
      const n = Sn.decrement();
      return `${text()} by P-Succ {
  ${parser.parse(`${n1} plus ${n2} is ${n}`)}
}`;
    }
  / Zero _ 'times' _ n:Nat _ 'is' _ Zero {
      return `${text()} by T-Zero {}`;
    }
  / Sn1:Nat _ 'times' _ n2:Nat _ 'is' _ n4:Nat {
      const n1 = Sn1.decrement();
      const n3 = n1.times(n2);
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

ReduceNatExp
  = e1:Exp _ '-*->' _ e2:Exp {
      // TODO: 簡約できない場合にはMR-Multiで分割
      return `${text()} by MR-One {
  ${parser.parse(`${e1} ---> ${e2}`)}
}`;
    }
  / n1:Nat _ '+' _ n2:Nat _ '--->' _ n3:Nat {
      return `${text()} by R-Plus {
  ${parser.parse(`${n1} plus ${n2} is ${n3}`)}
}`;
    }
  / n1:Nat _ '*' _ n2:Nat _ '--->' _ n3:Nat {
      return `${text()} by R-Times {
  ${parser.parse(`${n1} times ${n2} is ${n3}`)}
}`;
    }
  / e1:Exp _ '--->' _ e2:Exp {
      if (e1.op === '*') {
        if (e1.e1.toString() === e2.e1.toString()) {
          return `${text()} by R-TimesR {
  ${parser.parse(`${e1.e2} ---> ${e2.e2}`)}
}`;
        } else if (e1.e2.toString() === e2.e2.toString()) {
          return `${text()} by R-TimesL {
  ${parser.parse(`${e1.e1} ---> ${e2.e1}`)}
}`;
        }
      }
      if (e1.op === '+') {
        if (e1.e1.toString() === e2.e1.toString()) {
          return `${text()} by R-PlusR {
  ${parser.parse(`${e1.e2} ---> ${e2.e2}`)}
}`;
        } else if (e1.e2.toString() === e2.e2.toString()) {
          return `${text()} by R-PlusL {
  ${parser.parse(`${e1.e1} ---> ${e2.e1}`)}
}`;
        }
      }

      throw new Exception(`${text()} not matched`);
    }
  / n1:Nat _ '+' _ n2:Nat _ '-d->' _ n3:Nat {
      return `${text()} by DR-Plus {
  ${parser.parse(`${n1} plus ${n2} is ${n3}`)}
}`;
    }
  / n1:Nat _ '*' _ n2:Nat _ '-d->' _ n3:Nat {
      return `${text()} by DR-Times {
  ${parser.parse(`${n1} times ${n2} is ${n3}`)}
}`;
    }
  / e1:Exp _ '-d->' _ e2:Exp {
      if (e1.op === '*') {
        if (e1.e1.toString() === e2.e1.toString()) {
          return `${text()} by DR-TimesR {
  ${parser.parse(`${e1.e2} -d-> ${e2.e2}`)}
}`;
        } else if (e1.e2.toString() === e2.e2.toString()) {
          return `${text()} by DR-TimesL {
  ${parser.parse(`${e1.e1} -d-> ${e2.e1}`)}
}`;
        }
      }
      if (e1.op === '+') {
        if (e1.e1.toString() === e2.e1.toString()) {
          return `${text()} by DR-PlusR {
  ${parser.parse(`${e1.e2} -d-> ${e2.e2}`)}
}`;
        } else if (e1.e2.toString() === e2.e2.toString()) {
          return `${text()} by DR-PlusL {
  ${parser.parse(`${e1.e1} -d-> ${e2.e1}`)}
}`;
        }
      }

      throw new Exception(`${text()} not matched`);
    }

Nat
  = 'S(' _ nat:Nat _ ')' { return nat.increment(); }
  / Zero

Zero
  = 'Z' { return new Nat(0); }

Exp
  = e1:ExpTimes tail:(_ '+' _ ExpTimes)* {
      let result = e1;
      tail.forEach(e => {
        result = new Exp('+', result, e[3]);
      });
      return result;
    }
ExpTimes
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
