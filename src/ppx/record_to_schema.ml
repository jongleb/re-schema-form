open Migrate_parsetree
open Ast_mapper
open Asttypes
open Parsetree
open Ast_helper
open Field_create
open Utils

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
 
let pasre_opt_primitive core_type =
  match (core_type) with
  | [%type: int] -> Some([%expr Primitive(SInt)])
  | [%type: float] -> Some([%expr Primitive(SFloat)])
  | [%type: string] -> Some([%expr Primitive(SString)])
  | [%type: bool] -> Some([%expr Primitive(SBool)])
  | _ -> None

let rec parse_opt_obj ~(rest: structure_item list) core_type =
  match core_type.ptyp_desc with
  | Ptyp_constr({txt=Lident(li)}, _) ->
    rest 
      |> List.find_map (fun i -> 
          match i.pstr_desc with
          | Pstr_type(_, [d]) -> 
            if d.ptype_name.txt = li then Some(d) else None
          | _ -> None
        ) 
      |> Option.map(fun i ->
          let decls = match i.ptype_kind with
            | Ptype_record(r) -> r
            | _ -> Location.raise_errorf "Unexpected ptype_kind" in
          let arr = Exp.array(create_field_modules ~record_name:i ~rest decls) in
          [%expr SObject([%e arr])]
        )
  | _ -> None

and pasre_array_primitive core_type ~record_name ~rest label =
  match (core_type) with
  | ([%type: [%t? t] array]) -> Some([%expr SArr([%e parse_type ~record_name ~rest label])])
  | _ -> None

and parse_wrapped core_type ~rest (label: label_declaration) = 
  core_type 
  |> pasre_opt_primitive 
  <|> Lazy.from_fun(fun () -> parse_opt_obj ~rest label.pld_type)
  |> Option.map (fun r -> 
    let name = match core_type.ptyp_desc with
    | Ptyp_constr({txt=Lident(li)}, _) -> li
    | _ -> Location.raise_errorf "This type field is not supported" (* TODO: what? concrete location pls fix *) in 
    let root_field_module = name |> create_root |> Mod.mk |> Exp.pack in
    let root_ui_module = name |> Ui_create.create_root |> Mod.mk |> Exp.pack in
    [%expr 
      SchemaListItem(
        SchemaElement(
          r,
          [%e root_field_module],
          [%e root_ui_module]
        )
      )
    ]
  ) |> Option.get
  
    
and parse_type ~(record_name: type_declaration) ~rest (label: label_declaration) = 
  let apply = apply_to_schema_list_item (create_first_class_module ~record_name label) in
  let array = pasre_array_primitive label.pld_type ~record_name ~rest label in
  let primitive_opt = Lazy.from_fun(fun () -> pasre_opt_primitive label.pld_type) in
  let obj_opt = Lazy.from_fun(fun () -> parse_opt_obj ~rest label.pld_type) in
  let result = array <|> primitive_opt <|> obj_opt in
  match (result) with
    | Some(r) -> apply r
    | _ -> Location.raise_errorf "This type field is not supported" (* TODO: what? concrete location pls fix *)

and create_field_modules ~(record_name: type_declaration) ~(rest: structure_item list) (labels: Parsetree.label_declaration list) =
  List.map (parse_type ~record_name ~rest) labels

let create_schema (list: structure_item list) root =
  let decls = match root.ptype_kind with
    | Ptype_record(r) -> r
    | _ -> Location.raise_errorf "Unexpected ptype_kind" in
  let expressions = decls |> create_field_modules ~record_name:root ~rest:list |> Exp.array in
  let root_field_module = root.ptype_name.txt |> create_root |> Mod.mk |> Exp.pack in
  let root_ui_module = root.ptype_name.txt |> Ui_create.create_root |> Mod.mk |> Exp.pack in
  [[%stri
    let schema = SchemaElement(
      SObject([%e expressions]), [%e root_field_module], [%e root_ui_module]
    )
  ]]