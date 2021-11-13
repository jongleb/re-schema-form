open Migrate_parsetree
open Ast_mapper
open Asttypes
open Parsetree
open Ast_helper

let field_prefix = "Field"

let create_module_name (name: string Location.loc) = {
  txt = Some(String.concat "" [String.capitalize_ascii name.txt; field_prefix]);
  loc = Location.none;
}
  

let create_record_type record_name = [%stri
  type r = [%t Typ.mk(Ptyp_constr({ loc = Location.none; txt = Lident(record_name.txt)}, []))]
]

let create_getter ~(record_name: string Location.loc) label = 
let record_ident = Exp.ident { loc = Location.none; txt = Lident (record_name.txt)} in
let pexp_field = Pexp_field(record_ident, { loc = Location.none; txt = Lident(label.pld_name.txt)}) in
let exp = Exp.mk pexp_field in
[%stri 
  let get (value: t) = [%e exp]
] 

let create_setter ~(record_name: string Location.loc) label = 
  let fn_name_loc = Pat.var (Location.mknoloc "set") in
  let fn_arg_name_loc = Pat.var (Location.mknoloc label.pld_name.txt) in
  let fn_arg_record_name_loc = Pat.var (Location.mknoloc record_name.txt) in
  let record_spread_exp_descr = Exp.ident { loc = Location.none; txt = Lident(record_name.txt)} in
  let body = Pexp_construct(({txt = Lident(label.pld_name.txt);loc = Stdlib.(!) Ast_helper.default_loc;}, Some(record_spread_exp_descr))) in
  let fn_with_field_arg = Pexp_fun(Nolabel, None, fn_arg_name_loc, Exp.mk body) in
  let fn_with_field_record_arg = Pexp_fun(Nolabel, None, fn_arg_record_name_loc, Exp.mk fn_with_field_arg) in
  let value_bind = Vb.mk fn_name_loc (Exp.mk fn_with_field_record_arg) in
  Str.mk (Pstr_value(Nonrecursive, [value_bind]))


let create_field_module ~(record_name: string Location.loc) ~(rest: structure_item list) label = {
  pstr_loc = Location.none;
  pstr_desc = Pstr_module({
    pmb_name = create_module_name label.pld_name;
    pmb_attributes = [];
    pmb_loc = Location.none;
    pmb_expr = {
      pmod_attributes = [];
      pmod_loc = Location.none;
      pmod_desc = Pmod_structure([
        [%stri
          type t = [%t label.pld_type]
        ];
        create_record_type record_name;
        create_getter ~record_name label;
        create_setter ~record_name label;
      ])
    };
  })
}