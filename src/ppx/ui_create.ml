open Migrate_parsetree
open Ast_mapper
open Asttypes
open Parsetree
open Ast_helper

let get_widget label =
  Utils.get_attribute_or ~name:"sc_widget" label [%expr None] (fun e -> [%expr Some([%e e])])

let get_field label = 
    Utils.get_attribute_or ~name:"sc_field" label [%expr None] (fun e -> [%expr Some([%e e])])

let get_ui_stris label = 
  [
    [%stri
      let widget = [%e get_widget label]
    ];
    [%stri
      let field = [%e get_field label]
    ]
  ]   


let create_pmod_structure core_type label  = 
 Pmod_structure(
  label
   |> get_ui_stris |> List.append 
  [[%stri
   type t = [%t core_type]
  ];]
 )

 
let create_root txt  = 
 let type_t = Typ.constr { loc = Location.none; txt = Lident(txt)} [] in
 Pmod_structure([
    [%stri
      type t = [%t type_t]
    ];
    [%stri
      let widget = None
    ];
    [%stri
      let field = None
    ]
])

let create ~(record_name: type_declaration) label = 
  label 
    |> create_pmod_structure label.pld_type
    |> Mod.mk