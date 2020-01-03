let num = [%addFive 15];
Js.log(num); // Should print 20

module User = {
  [@deriving deriveFunction]
  type my_typ = {
    foo: int,
    bar: string,
  }; 
};

/*if you just wanna send gen flag
  *     [@deriving deriveFunctionWithArguments(gen)]
    or  [@deriving deriveFunctionWithArguments(~gen)]
    or  [@deriving deriveFunctionWithArguments({ gen })] (You can't use this syntax without giving another argument though)
    are the same.
*/
[@deriving deriveFunctionWithArguments({ name: "yusuf", gen })]
type dumbType = string;

Js.log(User.GM.foo_function()); // Should print foo function!
Js.log(User.GM.bar_function()); // Should print bar function!