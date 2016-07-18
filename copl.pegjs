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

Derivation
  = Zero _ 'plus' _ n:Expression _ 'is' _ n:Expression {
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


Expression
  = 'S(' _ nat:Expression _ ')' { return nat.increment(); }
  / Zero

Zero
  = 'Z' { return new Nat(0); }

_ 'whitespace'
  = [ \t\n\r]*
