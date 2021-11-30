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

let create ({pld_attributes}: label_declaration) = 
  let el = List.nth_opt pld_attributes 0 in
  match el with
  | Some({
      attr_name={txt="sc_meta"};
      attr_payload=PStr([{pstr_desc=Pstr_eval(e, _)}])}) -> [%expr Some([%e e])]
  | _ -> [%expr None]