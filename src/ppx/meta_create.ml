open Migrate_parsetree
open Ast_mapper
open Asttypes
open Parsetree
open Ast_helper

let create_if_not_exists struture_items = 
  let is_exists = List.exists (fun {pstr_desc} ->
      match pstr_desc with
      | Pstr_type(_, [{ptype_name={txt="sc_meta_data"}}]) -> true
      | _ -> false
    ) struture_items in
  if (is_exists)
  then []
  else [[%stri type sc_meta_data]]

let create (label: label_declaration) = 
  Utils.get_attribute_or ~name:"sc_meta" label [%expr None] (fun e -> [%expr Some([%e e])])