open Migrate_parsetree
open Ast_mapper
open Asttypes
open Parsetree
open Ast_helper

let create_pmod_structure ~(record_name: type_declaration) label  = 
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

let create ~(record_name: type_declaration) label = 
  label 
    |> create_pmod_structure ~record_name 
    |> Mod.mk