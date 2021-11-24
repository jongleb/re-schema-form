open Migrate_parsetree
open Ast_mapper
open Asttypes
open Parsetree
open Ast_helper

module Ast_builder = Ppxlib.Ast_builder.Default
module Ast_pattern = Ppxlib.Ast_pattern

let create_record_type record_name = [%stri
  type r = [%t Typ.mk(Ptyp_constr({ loc = Location.none; txt = Lident(record_name.ptype_name.txt)}, []))]
]

let create_getter ~(record_name: type_declaration) label = 
let record_ident = Exp.ident { loc = Location.none; txt = Lident (record_name.ptype_name.txt)} in
let pexp_field = Pexp_field(record_ident, { loc = Location.none; txt = Lident(label.pld_name.txt)}) in
let exp = Exp.mk pexp_field in
let arg_name = record_name.ptype_name.txt |> Location.mknoloc |> Pat.var in
[%stri 
  let get [%p arg_name] = [%e exp]
]

let create_setter ~(record_name: type_declaration) label =
  let open Ast_pattern in 
  let p_r = ptype_record (__) in
  let declarations = parse p_r record_name.ptype_loc record_name.ptype_kind in
  let get_record_arg_name = fun decls ->  
    if(List.length decls > 1) then
      (
        record_name.ptype_name.txt |> Location.mknoloc |> Pat.var,
        Some( Exp.ident { loc = Location.none; txt = Lident(record_name.ptype_name.txt)})
      )
    else
      ("_" |> Location.mknoloc |> Pat.var, None)
    in
  let (record_arg_name, in_record) = declarations get_record_arg_name in  
  let field_arg_name = label.pld_name.txt |> Location.mknoloc |> Pat.var in
  let body = 
    Ast_builder.pexp_record ~loc:Location.none 
    [(
      {txt = Lident(label.pld_name.txt);loc = Location.none;},  
      Exp.ident { loc = Location.none; txt = Lident(label.pld_name.txt)} 
    )] in_record in
  [%stri
    let set [%p record_arg_name] [%p field_arg_name] = [%e body]
  ]

let create_pmod_structure ~(record_name: type_declaration) label  = 
 Pmod_structure([
    [%stri
      type t = [%t label.pld_type]
    ];
    create_record_type record_name;
    [%stri
      type meta = string
    ];
    create_getter ~record_name label;
    create_setter ~record_name label;
])

let create_root (name: type_declaration) =
  let type_expr = Typ.constr { loc = Location.none; txt = Lident(name.ptype_name.txt) } [] in
  Pmod_structure([
    [%stri
      type t = [%t type_expr]
    ];
    [%stri
      type r = [%t type_expr]
    ];
    [%stri
      type meta = string
    ];
    [%stri
      let get (root: r) = root
    ];
    [%stri
      let set _ (root: r) = root
    ]
  ])

let create ~(record_name: type_declaration) label = 
  label 
    |> create_pmod_structure ~record_name
    |> Mod.mk