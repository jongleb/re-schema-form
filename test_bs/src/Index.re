let num = [%addFive 15];
Js.log(num); // Should print 20

module User = {
  [@deriving deriveFunction]
  type my_typ = {
    foo: int,
    bar: string,
  };
}

Js.log(User.GM.foo_function()); // Should print foo function!
Js.log(User.GM.bar_function()); // Should print bar function!