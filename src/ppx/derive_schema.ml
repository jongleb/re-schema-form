open Migrate_parsetree
open Ast_410
open Ast_mapper
open Asttypes
open Parsetree
open Ast_helper
open Schema_render_base

let gadtFieldName = "field"

let createType name = {
  pstr_loc = Location.none;
  pstr_desc = Pstr_type(Recursive, [
    {
      ptype_name = {
        txt = "t";
        loc = Location.none;
      };
      ptype_params = [];
      ptype_cstrs = [];
      ptype_private = Public;
      ptype_attributes = [];
      ptype_loc = Location.none;
      ptype_kind = Ptype_abstract;
      ptype_manifest = Some({
        ptyp_loc = Location.none;
        ptyp_attributes = [];
        ptyp_desc = Ptyp_constr({ loc = Location.none; txt = Lident(name.txt)}, []);
        ptyp_loc_stack = []
      });
    }
  ])
}

let createGetLens name fields = 
  let cases = List.map (fun field -> 
    let constr = Ast_helper.Pat.construct 
      { 
        loc = Location.none; 
        txt = Lident(String.capitalize_ascii(field.pld_name.txt)); 
      }
      None in
    let exp_field = Ast_helper.Exp.field
      [%expr values]
      { loc = Location.none; txt = Lident(field.pld_name.txt);} in 
    Ast_helper.Exp.case constr exp_field
  ) fields in 

  let gadtTypePoly =
    Ast_helper.Typ.mk (Ptyp_constr({txt = Lident(gadtFieldName); loc = Location.none }, [[%type: 'value]])) in 

  let gadtTypeLocal =
    Ast_helper.Typ.mk
      (Ptyp_constr({txt = Lident(gadtFieldName); loc = Location.none }, [[%type: value]])) in 

  let typeDefinition =
    Ast_helper.Typ.poly
      [{ txt = "value"; loc = Location.none }]
      ([%type: t -> [%t gadtTypePoly] -> 'value])
    |> Ast_helper.Typ.force_poly in 
  
  let typeDefinitionFilledWithPolyLocalType =
    [%type: t -> [%t gadtTypeLocal] -> value] in 
  
  let patMatch =
    Ast_helper.Exp.mk (
      Pexp_match(
        Ast_helper.Exp.mk (Pexp_ident({txt = Lident("field"); loc = Location.none})),
        cases
      )
    ) in
    
  let body = [%expr fun values -> fun field  -> [%e patMatch]] in
  let fnName = Ast_helper.Pat.var ({txt = "get"; loc = Location.none}) in 
  let pat = Ast_helper.Pat.constraint_ fnName typeDefinition in 
  let body =
    Ast_helper.Exp.constraint_ body typeDefinitionFilledWithPolyLocalType in
  [%stri let [%p pat] = fun (type value) -> [%e body]]

let createGadt fields = {
  pstr_loc = Location.none;
  pstr_desc =
    Pstr_type (
      Recursive, 
      [
        { 
          ptype_loc = Location.none; 
          ptype_attributes = [];
          ptype_name = {
            txt = gadtFieldName;
            loc = Location.none;
          };
          ptype_params = [
            (
              {
                ptyp_loc_stack = [];
                ptyp_desc = Ptyp_any;
                ptyp_loc = Location.none;
                ptyp_attributes = [];
              },
              Invariant
            )
          ];
          ptype_cstrs = [];
          ptype_private = Public;
          ptype_manifest = None;
          ptype_kind = Ptype_variant ( List.map (
            fun field -> {
              pcd_loc =  Location.none;
              pcd_attributes = [];
              pcd_name = {
                txt = String.capitalize_ascii field.pld_name.txt;
                loc = Location.none;
              };
              pcd_args = Pcstr_tuple([]);
              pcd_res = Some({
                ptyp_loc_stack = [];
                ptyp_loc = Location.none;
                ptyp_attributes = [];
                ptyp_desc = Ptyp_constr(
                  {txt = Lident(gadtFieldName); loc = Location.none},
                  [{
                    ptyp_desc = field.pld_type.ptyp_desc;
                    ptyp_loc_stack = [];
                    ptyp_loc = Location.none;
                    ptyp_attributes = [];
                  }]
                );
              })
            }) fields 
          )
        }
      ]
    )
}

let create_mk_field = [%stri type field_wrap = Mk_field : ('a, 'a field) schema -> field_wrap]

let try_parse_as_module i all_items =
  let opt = List.find_opt (fun ii -> ii.pld_name.txt == i.pld_name.txt) all_items in
  match opt with
    | None -> Location.raise_errorf "This type %s is not supported" i.pld_name.txt
    | _ -> 
      let pmod_desc = Pmod_ident({
        txt = Lident(String.capitalize_ascii i.pld_name.txt);
        loc = Stdlib.(!) Ast_helper.default_loc;
      }) in 
      let pexp_desc = Pexp_pack({
        pmod_desc;
        pmod_loc = Stdlib.(!) Ast_helper.default_loc;
        pmod_attributes = [];
      }) in 
      { 
        pexp_desc;
        pexp_loc = Stdlib.(!) Ast_helper.default_loc; 
        pexp_attributes = [];
        pexp_loc_stack = [];
      }

let parse_schema_item_type all_items i =
  let field_desc = Pexp_construct(
    {
      txt = Lident(String.capitalize_ascii i.pld_name.txt);
      loc = Stdlib.(!) Ast_helper.default_loc;
    },
    None
  ) in
  let field = {
    pexp_desc = field_desc;
    pexp_loc = Stdlib.(!) Ast_helper.default_loc;
    pexp_attributes = [];
    pexp_loc_stack = [];
  }  in
  match i.pld_type with
  | [%type: int] -> [%expr Mk_field(Schema_number([%e field]))]
  (* | [%type: float] => Some([%expr Schema.Number]) *)
  | [%type: string] -> [%expr Mk_field(Schema_string([%e field]))]
  | [%type: bool] -> [%expr Mk_field(Schema_booleang([%e field]))]
  | _ -> try_parse_as_module i all_items

let rec parse_schema_items items = List.map (parse_schema_item_type items) items

(* let rec parse_schema_items items = match items with
  | [] -> { 
      pexp_desc = Pexp_construct({
        txt = Lident("[]");
        loc = Stdlib.(!) Ast_helper.default_loc;
      }, None);
      pexp_loc = Stdlib.(!) Ast_helper.default_loc;
      pexp_attributes = [];
      pexp_loc_stack = [];
    }
  | h :: t -> 
    let parsed_expr = parse_schema_item_type h items in
    { 
      pexp_desc = Pexp_construct({
        txt = Lident("::");
        loc = Stdlib.(!) Ast_helper.default_loc;
      }, Some({
        pexp_desc = Pexp_tuple([parsed_expr; (parse_schema_items t)]);
        pexp_loc = Stdlib.(!) Ast_helper.default_loc;
        pexp_attributes = [];
        pexp_loc_stack = [];
      }));
      pexp_loc = Stdlib.(!) Ast_helper.default_loc;
      pexp_attributes = [];
      pexp_loc_stack = [];
    } *)
    
let create_schema_list list = [%stri
 let schema: field_wrap array = [%e Exp.array (parse_schema_items list)]
]

let createObjectModule name items = {
  pstr_loc = Location.none;
  pstr_desc = Pstr_module({
    pmb_name = {
      txt = Some(String.capitalize_ascii name.txt);
      loc = Location.none;
    };
    pmb_attributes = [];
    pmb_loc = Location.none;
    pmb_expr = {
      pmod_attributes = [];
      pmod_loc = Location.none;
      pmod_desc = Pmod_structure([
        createType name;
        createGadt items;
        create_mk_field;
        create_schema_list items;
        createGetLens name items;
      ])
    };
  })
}

let packModule i = match i with
  | Pstr_type (_, [{ ptype_kind; ptype_name }]) -> match ptype_kind with
    | Ptype_record (labels) -> createObjectModule ptype_name labels 

let create_structure_schema root items =  List.map packModule items

let createModule old_struture_items structure_items =
  let root = structure_items |> List.rev |> List.hd in 
  Mod.mk (
    Pmod_structure (
      List.append old_struture_items (create_structure_schema root structure_items)
        |> List.cons [%stri open Schema_object]
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

let () = Driver.register ~name:"lenses-ppx" (module OCaml_410) test_mapper