open Base;
open Ppxlib;

/*
  * This deriver only works with variants. Basically, it is useless and just written to show how argument thing works.
  * If you pass the "~gen" flag, it'll generate a function that returns the given "name" argument.
  * If you don't pass "~gen" flag, it generates nothing.

  * You can see the usage in the test_bs/src/Index.re file
*/

let str_gen = (~loc, ~path as _, (_rec: rec_flag, t: list(type_declaration)), name: option(string), gen: bool) => {
  let (module Builder) = Ast_builder.make(loc);
  let t = List.hd_exn(t);
  
  let pName = t.ptype_name.txt
  let functionName = Loc.make(~loc, pName ++ "_function");
  let functionPattern = Builder.ppat_var(functionName);

  switch (gen, name) {
  | (true, Some(name))  => [%str let [%p functionPattern] = () => [%e Builder.estring(pName ++ " function! || Name: " ++ name)]; ]
  | (true, None)        => [%str let [%p functionPattern] = () => [%e Builder.estring(pName ++ " function without name!")]; ]
  | (false, _)          => []
  };
};

let name = "deriveFunctionWithArguments";

let () = {
  let args =
    Deriving.Args.(
      empty
      +> arg("name", estring(__))
      +> flag("gen")
    );


  let str_type_decl = Deriving.Generator.make(args, str_gen);

  Deriving.add(name, ~str_type_decl) |> Deriving.ignore;
};