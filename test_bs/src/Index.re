let num = [%addFive 15];
Js.log(num);

module User = {
  [@deriving deriveFunction]
  type my_typ = {
    foo: int,
    j: string,
  };
}