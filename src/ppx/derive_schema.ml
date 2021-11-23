open Migrate_parsetree
open Ast_410
open Ast_mapper
open Asttypes
open Parsetree
open Ast_helper
open Record_to_schema


let create_structure_schema items = items
  |> List.find_map ( fun {pstr_desc} -> 
    match pstr_desc with
    | Pstr_type(_, [d]) -> Some(d)
    | _ -> None
  )
  |> Option.map (create_schema items)
  |> Option.value ~default:[]

let createModule struture_items =
  Mod.mk (
    Pmod_structure (
      List.append struture_items (create_structure_schema struture_items)
        |> List.cons [%stri open Schema]
    )
  )

let map_module_expr mapper expr = match expr with
  | { pmod_desc = Pmod_extension ({ txt = "schema" },
      PStr(structure_items)) 
    } -> createModule structure_items
  | other -> default_mapper.module_expr mapper expr

let schema_mapper = {
 default_mapper with 
 module_expr = map_module_expr
}

let test_mapper _ _ = schema_mapper

let () = Driver.register ~name:"re_schema_form" (module OCaml_410) test_mapper