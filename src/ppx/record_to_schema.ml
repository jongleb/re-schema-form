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

let apply_to_schema_list_item label (fn: (module Create_first_class) -> expression) expr = 
  [%expr 
    SchemaListItem(
      [%e expr],
      [%e fn (module(Field_create))],
      [%e fn (module(Ui_create))],
      [%e Meta_create.create label]
    )
  ]

let field_not_supported () = Location.raise_errorf "This type field is not supported"   
 
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

and pasre_array_primitive core_type ~record_name ~rest (label: label_declaration) =
  match (core_type) with
  | ([%type: [%t? t] array]) -> begin
      t 
       |> parse_opt_as ~record_name ~rest label
       |> Option.map (fun r -> 
          let ui = label |> Ui_create.create_pmod_structure t |> Mod.mk in
          [%expr SArr([%e r], [%e (Exp.mk (Pexp_pack(ui)))])]
        ) 
      (* TODO: not all 
      recursive levels ui schema of 
      course it's temporary, fix it in feature as other uischema fields *)
    end
  | _ -> None

and parse_opt_as ~(record_name: type_declaration) ~rest (label: label_declaration) core_type = 
  let array = pasre_array_primitive core_type ~record_name ~rest label in
  let primitive_opt = Lazy.from_fun(fun () -> pasre_opt_primitive core_type) in
  let obj_opt = Lazy.from_fun(fun () -> parse_opt_obj ~rest core_type) in
  array <|> primitive_opt <|> obj_opt  
and parse_type ~(record_name: type_declaration) ~rest (label: label_declaration) = 
  let apply = apply_to_schema_list_item label (create_first_class_module ~record_name label) in
  let result = parse_opt_as ~record_name ~rest label label.pld_type in
  match (result) with
  | Some(r) -> apply r
  | _ -> field_not_supported() (* TODO: what? concrete location pls fix *)

and create_field_modules ~(record_name: type_declaration) ~(rest: structure_item list) (labels: Parsetree.label_declaration list) =
  List.map (parse_type ~record_name ~rest) labels

let create_schema (list: structure_item list) root =
  let decls = match root.ptype_kind with
    | Ptype_record(r) -> r
    | _ -> Location.raise_errorf "Unexpected ptype_kind" in
  let expressions = decls |> create_field_modules ~record_name:root ~rest:list |> Exp.array in
  let root_ui_module = root.ptype_name.txt |> Ui_create.create_root |> Mod.mk |> Exp.pack in
  let root_type_name = Typ.constr { loc = Location.none; txt = Lident(root.ptype_name.txt)} []in
  [
    [%stri
    let schema: 
      (obj, 
       [%t root_type_name],
       [%t root_type_name], 
       sc_meta_data
      ) Schema.t =
      SObject([%e expressions])
    ];
    [%stri
      let uiSchema: (module(FieldUiSchema with type t = [%t root_type_name])) = [%e root_ui_module]
    ]
  ]