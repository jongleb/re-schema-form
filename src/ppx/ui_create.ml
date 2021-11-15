open Migrate_parsetree
open Ast_mapper
open Asttypes
open Parsetree
open Ast_helper

let create_pmod_structure ~(record_name: string Location.loc) label  = 
 Pmod_structure([
    [%stri
      type t = [%t label.pld_type]
    ];
    [%stri
      let widget = None
    ];
    [%stri
      let field = None
    ]
])

let create_first_class_ui_module ~(record_name: string Location.loc) label = 
  label 
    |> create_pmod_structure ~record_name 
    |> Mod.mk