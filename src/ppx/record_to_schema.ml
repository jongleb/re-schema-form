open Migrate_parsetree
open Ast_mapper
open Asttypes
open Parsetree
open Ast_helper
open Field_create

module type CreateFirstClass = sig
  val create: record_name: string Location.loc -> label_declaration ->  Parsetree.module_expr
end

let create_first_class_module ~(record_name: string Location.loc) label (module M: CreateFirstClass) = 
  Exp.mk (Pexp_pack(M.create ~record_name label))

let apply_to_schema_list_item (fn: (module CreateFirstClass) -> expression) expr = 
  [%expr 
    SchemaListItem(SchemaElement([%e expr])), 
    [%e fn (module(Field_create))],
    [%e fn (module(Ui_create))]
  ]

let get_option_primitive t = 
  match t with
  | [%type: int] -> Some([%expr SInt])
  | [%type: float] -> Some([%expr SFloat])
  | [%type: string] -> Some([%expr SStrig])
  | [%type: bool] -> Some([%expr SBool])
  | _ -> None
let rec parse_as_complex (i: core_type) (label: label_declaration) = 
  match i.ptyp_desc with
    | Ptyp_constr(id_loc, []) -> Location.raise_errorf "This type field %s is not supported" label.pld_name.txt
    | Ptyp_constr({txt=Lident(s)}, w :: []) -> 
        let a = match s with
          | "option" -> "Supports only one wrapper"
          | "array" -> Location.raise_errorf "Supports only one wrapper"
          | _ -> Location.raise_errorf "Supports only one wrapper"
        in [%expr ""]
    | Ptyp_constr(id_loc, _) -> Location.raise_errorf "Supports only one wrapper"
    | _ -> Location.raise_errorf "This type field %s is not supported" label.pld_name.txt

and parse_type ~(record_name: string Location.loc) (label: label_declaration) = 
  let apply = apply_to_schema_list_item (create_first_class_module ~record_name label) in
  let option_primitive = get_option_primitive label.pld_type in
  match (option_primitive, label.pld_type) with
    | (Some(r), _) -> apply [%expr Primitive([%e r])]
    | (_, [%type: [%type: 'b] array]) -> apply [%expr Primitive(SBool)]
    | (_, [%type: [%type: 'b] option]) -> apply [%expr Primitive(SBool)]
    | (_, i) -> parse_as_complex i label

let create_field_modules ~(record_name: string Location.loc) ~(rest: structure_item list) (labels: Parsetree.label_declaration list) =
  List.map (fun label -> 
    let with_args = create_first_class_module ~record_name label in 
    [%stri
      let schema = SchemaListItem(
        SchemaElement(
          
        ), 
        [%e with_args (module(Field_create))],
        [%e with_args (module(Ui_create))]
      )
    ]
) labels