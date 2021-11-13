open Migrate_parsetree
open Ast_mapper
open Asttypes
open Parsetree
open Ast_helper
open Field_create

let create_field_modules ~(record_name: string Location.loc) ~(rest: structure_item list) (labels: Parsetree.label_declaration list) =
  let create_with_name = create_field_module ~record_name ~rest in
  List.map (create_with_name) labels