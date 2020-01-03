open Base;
open Ppxlib;

/*
  * This deriver only works with records.
  * It generates a function for each label_decleration(field) by its name.
  * Converts that functions (structure_items) to the module_expression and returns a module called GM.
  * That module includes all the generated functions in it.

  * You can see the usage in the test_bs/src/Index.re file
*/

let getFieldName = (field: label_declaration) => field.pld_name |> Loc.txt;

let generateFieldFunction = (loc, field) => {
  let (module Builder) = Ast_builder.make(loc);

  let fieldName = getFieldName(field);
  let functionName = Loc.make(~loc, fieldName ++ "_function");
  let functionPattern = Builder.ppat_var(functionName);
  
  [%stri
    let [%p functionPattern] = () => [%e Builder.estring(fieldName ++ " function!")];
  ]
}

let recordHandler = (loc: Location.t, _recFlag: rec_flag, _t: type_declaration, fields: list(label_declaration)) => {
  let (module Builder) = Ast_builder.make(loc);

  let generatedFunctions = fields |> List.map(~f= (field) => generateFieldFunction(loc, field));
  let moduleExpr = Builder.pmod_structure(generatedFunctions);

  [%str
    module GM = [%m moduleExpr]
  ]
}

let str_gen = (~loc, ~path as _, (_rec: rec_flag, t: list(type_declaration))) => {
  let t = List.hd_exn(t);

  switch t.ptype_kind {
  | Ptype_record(fields) => recordHandler(loc, _rec, t, fields);
  | _ => Location.raise_errorf(~loc, "deriveFunction only works on records.");
  };
};
let name = "deriveFunction";

let () = {
  let str_type_decl = Deriving.Generator.make_noarg(str_gen);
  Deriving.add(name, ~str_type_decl) |> Deriving.ignore;
};