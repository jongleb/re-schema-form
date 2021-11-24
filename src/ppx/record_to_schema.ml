open Migrate_parsetree
open Ast_mapper
open Asttypes
open Parsetree
open Ast_helper
open Field_create

module type Create_first_class = sig
  val create: record_name: type_declaration -> label_declaration ->  Parsetree.module_expr
end

let create_first_class_module ~(record_name: type_declaration) label (module M: Create_first_class) = 
  Exp.mk (Pexp_pack(M.create ~record_name label))

let apply_to_schema_list_item (fn: (module Create_first_class) -> expression) expr = 
  [%expr 
    SchemaListItem(
      SchemaElement(
        [%e expr],
        [%e fn (module(Field_create))],
        [%e fn (module(Ui_create))]
      )
    )
  ]

let rec get_option_object t ~rest = 
 match t.ptyp_desc with
 | Ptyp_constr(loc, _) -> 
    List.find_opt (fun i -> 
      match i with
      | Pstr_type(_, [{ptype_name={txt}}]) -> txt == ""
      | _ -> false
    ) rest
 | _ -> Location.raise_errorf "This type field is not supported" (*TODO: fix*)
  
and parse_type ?wrapped:(wrapped=false) ~(record_name: type_declaration) ~rest (label: label_declaration) = 
  let apply = apply_to_schema_list_item (create_first_class_module ~record_name label) in
  match (label.pld_type) with
    | ([%type: [%t? t] array]) -> apply [%expr SArr([%e parse_type ~wrapped ~record_name ~rest label])]
    | ([%type: [%t? t] option]) -> Location.raise_errorf "Option not implemented" (* TODO *)
    | [%type: int] -> apply [%expr Primitive(SInt)]
    | [%type: float] -> apply [%expr Primitive(SFloat)]
    | [%type: string] -> apply [%expr Primitive(SString)]
    | [%type: bool] -> apply [%expr Primitive(SBool)]
    | (_) -> Location.raise_errorf "This type field is not supported" (* TODO: what? concrete location pls fix *)

and create_field_modules ~(record_name: type_declaration) ~(rest: structure_item list) (labels: Parsetree.label_declaration list) =
  List.map (parse_type ~record_name ~rest) labels

let create_schema (list: structure_item list) root =
  let decls = match root.ptype_kind with
    | Ptype_record(r) -> r
    | _ -> Location.raise_errorf "Unexpected ptype_kind" in
  let expressions = decls |> create_field_modules ~record_name:root ~rest:list |> Exp.array in
  let root_field_module = root |> create_root |> Mod.mk |> Exp.pack in
  let root_ui_module = root |> Ui_create.create_root |> Mod.mk |> Exp.pack in
  [[%stri
    let schema = SchemaElement(
      SObject([%e expressions]), [%e root_field_module], [%e root_ui_module]
    )
  ]]