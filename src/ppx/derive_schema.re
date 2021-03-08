open Ppxlib;
open Schema_render_base;

let getFieldName = (field: label_declaration) => field.pld_name |> Loc.txt;

let parseSimpleType = (l: core_type) => {
  switch l {
    | [%type: int] => Schema.Number
    | [%type: float] => Schema.Number
    | _ => Location.raise_errorf("the type cannot be parsed")
  }
}

let mkSchemaType = (field: label_declaration) => {
  switch field.pld_type.ptyp_desc {
    | Ptyp_constr(l, _) => parseSimpleType(field.pld_type)
    | _ =>  Location.raise_errorf("use only simple types");
  }
}

let mkSchemaField = (loc, field): Schema.t => {
  let (module Builder) = Ast_builder.make(loc);
  let name = getFieldName(field);
  let _type = mkSchemaType(field);
  let properties = [];
  { name, _type, properties }
}

let recordHandler = (loc: Location.t, _recFlag: rec_flag, _t: type_declaration, fields: list(label_declaration)) => {
  let (module Builder) = Ast_builder.make(loc);

  let generated = fields |> List.map(f => mkSchemaField(loc, f));

  let test = [%str
    include Schema;
    let schema: t = { name: "", _type: String, properties: [] }
  ]
  let moduleExpr = Builder.pmod_structure(test);

  [%str
    module S = [%m moduleExpr]
  ]
}

let str_gen = (~loc, ~path as _, (_rec: rec_flag, t: list(type_declaration))) => {
  let t = List.hd(t)

  switch t.ptype_kind {
  | Ptype_record(fields) => recordHandler(loc, _rec, t, fields);
  | _ => Location.raise_errorf(~loc, "schema is used only for records.");
  };
};
let name = "schema";

let () = {
  let str_type_decl = Deriving.Generator.make_noarg(str_gen);
  Deriving.add(name, ~str_type_decl) |> Deriving.ignore;
};