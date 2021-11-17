open Migrate_parsetree
open Ast_410
open Ast_mapper
open Asttypes
open Parsetree
open Ast_helper
open Field_create

let create_structure_schema pstr_descs = List.concat_map (packModule ~rest) pstr_descs

let createModule old_struture_items pstr_descs =
  Mod.mk (
    Pmod_structure (
      List.append old_struture_items (create_structure_schema pstr_descs)
        |> List.cons [%stri open Schema]
    )
  )

let map_module_expr mapper expr = match expr with
  | { pmod_desc = Pmod_extension ({ txt = "schema" },
      PStr(structure_items)) 
    } -> createModule structure_items (List.map (fun i -> i.pstr_desc) structure_items )
  | other -> default_mapper.module_expr mapper expr

let schema_mapper = {
 default_mapper with 
 module_expr = map_module_expr
}

let test_mapper _ _ = schema_mapper

let () = Driver.register ~name:"re_schema_form" (module OCaml_410) test_mapper