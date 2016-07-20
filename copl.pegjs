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
    multiply(nat) {
      return new Nat(this.n * nat.n);
    }
  }
}

start
  = Derivation
  / CompareNat1

Derivation
  = Zero _ 'plus' _ n1:Expression _ 'is' _ n2:Expression {
      // TODO: check if n1 is equal to n2
      return `${text()} by P-Zero {}`;
    }
  / Sn1:Expression _ 'plus' _ n2:Expression _ 'is' _ Sn:Expression {
      const n1 = Sn1.decrement();
      const n = Sn.decrement();
      return `${Sn1} plus ${n2} is ${Sn} by P-Succ {
  ${parser.parse(`${n1} plus ${n2} is ${n}`)}
}`;
    }
  / Zero _ 'times' _ n:Expression _ 'is' _ Zero {
      return `${text()} by T-Zero {}`;
    }
  / Sn1:Expression _ 'times' _ n2:Expression _ 'is' _ n4:Expression {
      const n1 = Sn1.decrement();
      const n3 = n1.multiply(n2);
      return `${text()} by T-Succ {
  ${parser.parse(`${n1} times ${n2} is ${n3}`)};
  ${parser.parse(`${n2} plus ${n3} is ${n4}`)};
}`;
    }

CompareNat1
  = n1:Expression _ 'is' _ 'less' _ 'than' _ n3:Expression {
      if (n1.n + 1 === n3.n) {
        return `${text()} by L-Succ {}`;
      }

      const n2 = n1.increment();
      return `${text()} by L-Trans {
  ${parser.parse(`${n1} is less than ${n2}`)};
  ${parser.parse(`${n2} is less than ${n3}`)};
}`;
    }


Expression
  = 'S(' _ nat:Expression _ ')' { return nat.increment(); }
  / Zero

Zero
  = 'Z' { return new Nat(0); }

_ 'whitespace'
  = [ \t\n\r]*
