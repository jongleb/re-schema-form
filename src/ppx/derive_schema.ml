open Migrate_parsetree
open Ast_410
open Ast_mapper
open Asttypes
open Parsetree
open Ast_helper

let gadtFieldName = "field"

let create_schema_config_name txt = String.concat "_" [String.capitalize_ascii txt; "schema_config"]
let initial_types = []

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

(* Taken from https://github.com/Astrocoders/lenses-ppx/blob/master/packages/ppx/src/LensesPpx.re  *)
let create_get_lens name fields = 
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


(* Taken from https://github.com/Astrocoders/lenses-ppx/blob/master/packages/ppx/src/LensesPpx.re  *)
let create_set_lens name fields = 
  let cases = List.map (fun field -> 
    let constr = Ast_helper.Pat.construct 
      { 
        loc = Location.none; 
        txt = Lident(String.capitalize_ascii(field.pld_name.txt)); 
      }
      None in
    let exp_field = Ast_helper.Exp.record
      [(
        {
          loc = Stdlib.(!) Ast_helper.default_loc; 
          txt = Lident(field.pld_name.txt)
        }, 
        [%expr value]
      )]
      (if List.length fields > 1 then Some([%expr values]) else None)
     in
    Ast_helper.Exp.case constr exp_field
  ) fields in
  let gadtTypePoly =
    Ast_helper.Typ.mk (Ptyp_constr({txt = Lident(gadtFieldName); loc = Location.none }, [[%type: 'value]])) in
  let gadtTypeLocal =
    Ast_helper.Typ.mk
      (Ptyp_constr({txt = Lident(gadtFieldName); loc = Location.none }, [[%type: value]])) in 
  let typeDefinition =
    Ast_helper.Typ.poly
      [{txt = "value"; loc = Location.none; }]
      [%type: t -> [%t gadtTypePoly] -> 'value -> t]
      |> Ast_helper.Typ.force_poly in   
  let typeDefinitionFilledWithPolyLocalType = [%type:
      t -> [%t gadtTypeLocal] -> value -> t
    ] in

  let patMatch =
    Ast_helper.Exp.mk (
      Pexp_match(
        Ast_helper.Exp.mk (Pexp_ident({txt = Lident("field"); loc = Location.none})),
          cases
        )
      ) in  
  let body = [%expr fun values -> fun field -> fun value -> [%e patMatch]] in
  let fnName = Ast_helper.Pat.var ({txt = "set"; loc = Location.none}) in 
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

let create_mk_field = [%stri
  type field_wrap = 
    | Mk_field : ('a, 'a field, m) schema * m -> field_wrap
    | Mk_nullable_field : ('a, 'a option field, m) schema * m -> field_wrap
    | Mk_array_field : ('a, 'a array field, m) schema * m -> field_wrap
]

let create_field_meta field = 
  let is_field_meta { attr_name = { txt }; attr_payload } = String.compare txt "schema.meta" == 0 in
    field.pld_attributes 
    |> List.find_opt is_field_meta
    |> Option.map(fun { attr_name = { txt }; attr_payload } ->
      let parse_struct s = match s with 
              | [] -> [%expr None]
              | { pstr_desc } :: xs -> 
                match pstr_desc with
                  | Pstr_eval(exp, _) -> [%expr Some([%e exp])]
                  | _ ->  [%expr None]
            in
            match attr_payload with
              | PStr(s) -> parse_struct s
              | _ -> [%expr None]
      ) 
    |> Option.value ~default:[%expr None]

let try_parse_as_module ~rest i =
  let type_name = match i.pld_type.ptyp_desc with
    | Ptyp_constr({ txt = Lident(s) }, _) -> s
    | _ -> Location.raise_errorf "This type field %s is not supported" i.pld_name.txt in
  let field_name = String.capitalize_ascii i.pld_name.txt in
  let pmod_desc = Pmod_ident({
    txt = Lident(create_schema_config_name type_name);
    loc = Stdlib.(!) Ast_helper.default_loc;
  }) in 
  let pexp_desc = Pexp_pack({
    pmod_desc;
    pmod_loc = Stdlib.(!) Ast_helper.default_loc;
    pmod_attributes = [];
  }) in
  let pexp_packed = { 
    pexp_desc;
    pexp_loc = Stdlib.(!) Ast_helper.default_loc; 
    pexp_attributes = [];
    pexp_loc_stack = [];
  } in
  let field_construct = Pexp_construct({
    txt = Lident(field_name);
    loc = Stdlib.(!) Ast_helper.default_loc;
  }, None) in
  let field_expr = {
    pexp_desc = field_construct;
    pexp_loc = Stdlib.(!) Ast_helper.default_loc; 
    pexp_attributes = [];
    pexp_loc_stack = [];
  } in 
  let tuple_expr = {
    pexp_desc = Pexp_tuple([field_expr; pexp_packed]);
    pexp_loc = Stdlib.(!) Ast_helper.default_loc;
    pexp_attributes = [];
    pexp_loc_stack = [];
  } in 
  [%expr Mk_field(Schema_object([%e tuple_expr]), [%e create_field_meta i])]


let parse_schema_item_type ~rest all_items i =
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
  | [%type: int] -> [%expr Mk_field(Schema_number([%e field], Schema_number_int), [%e create_field_meta i])]
  | [%type: float] -> [%expr Mk_field(Schema_number([%e field], Schema_number_float), [%e create_field_meta i])]
  | [%type: string] -> [%expr Mk_field(Schema_string([%e field]), [%e create_field_meta i])]
  | [%type: bool] -> [%expr Mk_field(Schema_boolean([%e field]), [%e create_field_meta i])]
  | [%type: int option] -> [%expr Mk_nullable_field(Schema_number([%e field], Schema_number_int), [%e create_field_meta i])]
  | [%type: float option] -> [%expr Mk_nullable_field(Schema_number([%e field], Schema_number_float), [%e create_field_meta i])]
  | [%type: string option] -> [%expr Mk_nullable_field(Schema_string([%e field]), [%e create_field_meta i])]
  | [%type: bool option] -> [%expr Mk_nullable_field(Schema_boolean([%e field]), [%e create_field_meta i])]
  | [%type: int array] -> [%expr Mk_array_field(Schema_number([%e field], Schema_number_int), [%e create_field_meta i])]
  | [%type: float array] -> [%expr Mk_array_field(Schema_number([%e field], Schema_number_float), [%e create_field_meta i])]
  | [%type: string array] -> [%expr Mk_array_field(Schema_string([%e field]), [%e create_field_meta i])]
  | [%type: bool array] -> [%expr Mk_array_field(Schema_boolean([%e field]), [%e create_field_meta i])]
  | _ -> try_parse_as_module ~rest i

let rec parse_schema_items ~rest items = List.map (parse_schema_item_type ~rest items) items

let create_field_renders fields = 
  let create_render f = match f.pld_attributes with 
    | [] -> None
    | { attr_name = { txt }; attr_payload } :: xs -> 
      if String.compare txt "schema.ui.render" != 0
        then None
      else
        let parse_struct s = match s with 
          | [] -> None
          | { pstr_desc } :: xs -> 
            match pstr_desc with
              | Pstr_eval(x, _) -> 
                let tuple = Ast_helper.Exp.tuple [
                  {
                    pexp_loc = Location.none;
                    pexp_loc_stack = [];
                    pexp_attributes = [];
                    pexp_desc = Pexp_construct({
                      txt = Lident(String.capitalize_ascii f.pld_name.txt);
                      loc = Stdlib.(!) Ast_helper.default_loc;
                    }, None)
                  };
                  x
                ] in 
                let constr = [%expr Mk_field_render([%e tuple])] in 
                Some constr
              | _ -> None
        in
        match attr_payload with
          | PStr(s) -> parse_struct s
          | _ -> None  
  in
  fields |> List.filter_map (create_render) |> Exp.array

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
    
let create_schema_list ~rest list = [%stri
 let schema: field_wrap array = [%e Exp.array (parse_schema_items ~rest list)]
]

let create_object_module ~rest name items = {
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
        [%stri type m = schema_meta option];
        createGadt items;
        create_mk_field;
        create_schema_list ~rest items;
        create_get_lens name items;
        create_set_lens name items;
      ])
    };
  })
}

let create_field_eq_cases fields = 
  let create_case_const f = Ast_helper.Pat.construct 
    { 
      loc = Location.none; 
      txt = Lident(String.capitalize_ascii(f.pld_name.txt)); 
    }
    None
  in
  let same_cases f = List.init 2 (fun _ -> create_case_const f) in
  let create_tuple f = f |> same_cases |> Ast_helper.Pat.tuple in
  let create_constr f = Ast_helper.Exp.case (create_tuple f) [%expr Some Eq] in
  let none = Ast_helper.Exp.case (Ast_helper.Pat.any ()) [%expr None] in
  [fields |> List.map (create_constr); [none]] |> List.flatten
let create_field_eq_matches fields = { 
  pexp_desc = Pexp_match(
    {
      pexp_desc = Pexp_tuple(
        [
          {
            pexp_desc = Pexp_ident({ loc = Location.none; txt = Lident("a") });
            pexp_loc = Location.none;
            pexp_attributes = [];
            pexp_loc_stack = [];
          };
          {
            pexp_desc = Pexp_ident({ loc = Location.none; txt = Lident("b") });
            pexp_loc = Location.none;
            pexp_attributes = [];
            pexp_loc_stack = [];
          }
        ]
      );
      pexp_loc = Location.none;
      pexp_attributes = [];
      pexp_loc_stack = [];
    },
    create_field_eq_cases fields;
  );
  pexp_loc = Location.none;
  pexp_attributes = [];
  pexp_loc_stack = [];
}
  
let create_field_eq fields = 
  let pattern = {
      ppat_desc = Ppat_var({
        txt = "field_eq";
        loc = Location.none;
      });
      ppat_loc = Location.none;
      ppat_attributes = [];
      ppat_loc_stack = [];
  } in
  let fun_expr = {
    pexp_desc = Pexp_constraint(
      create_field_eq_matches fields,
      {
        ptyp_desc = Ptyp_constr({
           loc = Location.none; txt = Lident("option")}, [
             {
              ptyp_desc = Ptyp_constr({
                loc = Location.none; txt = Lident("eq")}, [
                  {
                   ptyp_desc = Ptyp_constr({
                     loc = Location.none; txt = Lident("a")}, []
                   );
                   ptyp_loc = Location.none;
                   ptyp_attributes = [];
                   ptyp_loc_stack = [];
                  };
                  {
                   ptyp_desc = Ptyp_constr({
                     loc = Location.none; txt = Lident("b")}, []
                   );
                   ptyp_loc = Location.none;
                   ptyp_attributes = [];
                   ptyp_loc_stack = [];
                  }
                ]
              );
              ptyp_loc = Location.none;
              ptyp_attributes = [];
              ptyp_loc_stack = [];
             }
           ]
        );
        ptyp_loc = Location.none;
        ptyp_attributes = [];
        ptyp_loc_stack = [];
      }
    );
    pexp_loc = Location.none;
    pexp_attributes = [];
    pexp_loc_stack = [];
  } in
  let b_arg_pattern = {
    ppat_desc = Ppat_constraint(
      {
        ppat_desc = Ppat_var(
          { txt = "b";
            loc = Location.none
          }
        );
        ppat_loc = Location.none;
        ppat_attributes = [];
        ppat_loc_stack = [];
      },
      {
        ptyp_desc = Ptyp_constr({
           loc = Location.none; txt = Lident("field")}, [
             {
              ptyp_desc = Ptyp_constr({
                loc = Location.none; txt = Lident("b")}, []
              );
              ptyp_loc = Location.none;
              ptyp_attributes = [];
              ptyp_loc_stack = [];
             }
           ]
        );
        ptyp_loc = Location.none;
        ptyp_attributes = [];
        ptyp_loc_stack = [];
      }
    );
    ppat_loc = Location.none;
    ppat_attributes = [];
    ppat_loc_stack = [];
  } in
  let pexp_fun_b = Pexp_fun(
    Nolabel,
    None,
    b_arg_pattern,
    fun_expr
  ) in
  let a_arg_pattern = {
    ppat_desc = Ppat_constraint(
      {
        ppat_desc = Ppat_var(
          { txt = "a";
            loc = Location.none
          }
        );
        ppat_loc = Location.none;
        ppat_attributes = [];
        ppat_loc_stack = [];
      },
      {
        ptyp_desc = Ptyp_constr({
           loc = Location.none; txt = Lident("field")}, [
             {
              ptyp_desc = Ptyp_constr({
                loc = Location.none; txt = Lident("a")}, []
              );
              ptyp_loc = Location.none;
              ptyp_attributes = [];
              ptyp_loc_stack = [];
             }
           ]
        );
        ptyp_loc = Location.none;
        ptyp_attributes = [];
        ptyp_loc_stack = [];
      }
    );
    ppat_loc = Location.none;
    ppat_attributes = [];
    ppat_loc_stack = [];
  } in
  let pexp_fun_a = Pexp_fun(
    Nolabel,
    None,
    a_arg_pattern,
    {
      pexp_loc = Location.none;
      pexp_attributes = [];
      pexp_loc_stack = [];
      pexp_desc = pexp_fun_b
    }
  ) in
  let expression_fun = {
    pexp_loc = Location.none;
    pexp_attributes = [];
    pexp_loc_stack = [];
    pexp_desc = pexp_fun_a
  } in
  let pexp_newtype_b = Pexp_newtype(
    {
      txt = "b";
      loc = Location.none;
    },
    expression_fun
  ) in
  let expression_b = {
    pexp_loc = Location.none;
    pexp_attributes = [];
    pexp_loc_stack = [];
    pexp_desc = pexp_newtype_b
  } in
  let pexp_newtype_a = Pexp_newtype(
    {
      txt = "a";
      loc = Location.none;
    },
    expression_b
  ) in
  let expression = {
    pexp_loc = Location.none;
    pexp_attributes = [];
    pexp_desc = pexp_newtype_a;
    pexp_loc_stack = [];
  } in
  let value_binding = {
    pvb_pat = pattern;
    pvb_attributes = [];
    pvb_loc = Location.none;
    pvb_expr = expression
  } in 
  {
    pstr_loc = Location.none;
    pstr_desc = Pstr_value(
      Nonrecursive,
      [
        value_binding
      ]
    )
  }

let create_schema_config_module ~rest name items = {
  pstr_loc = Location.none;
  pstr_desc = Pstr_module({
    pmb_name = {
      txt = Some(create_schema_config_name name.txt);
      loc = Location.none;
    };
    pmb_attributes = [];
    pmb_loc = Location.none;
    pmb_expr = {
      pmod_attributes = [];
      pmod_loc = Location.none;
      pmod_desc = Pmod_structure([
        { pstr_desc = Pstr_include({
          pincl_loc = Location.none;
          pincl_attributes = [];
          pincl_mod = {
            pmod_attributes = [];
            pmod_loc = Location.none;
            pmod_desc = Pmod_ident({
              txt = Lident(String.capitalize_ascii name.txt);
              loc = Stdlib.(!) Ast_helper.default_loc;
            })
          }
        });
          pstr_loc = Location.none;
        };
        [%stri 
          type field_render =
            Mk_field_render : ('a field * (module FieldRender with type t = 'a)) -> field_render   
        ];
        [%stri type field_renders = field_render array];
        [%stri 
          let field_renders: field_renders = [%e create_field_renders items]
        ];
        [%stri
          type (_,_) eq = Eq : ('a, 'a) eq
        ];
        create_field_eq items;
        [%stri
          let get_dyn : type a. a field -> field_render -> (module FieldRender with type t = a) option =
            fun a (Mk_field_render(b, x)) ->
              match field_eq a b with
                | None -> None
                | Some Eq -> Some x  
        ];
        [%stri
          let get_field_render f =
            let rec loop (l: field_renders) = match Array.length l with
              | 0 -> None
              | _ -> 
                let sub_cnt = Array.length l - 1 in
                match get_dyn f l.(0) with 
                  | None -> loop (Array.sub l 1 sub_cnt)
                  | v -> v
                in           
                loop field_renders 
        ];
      ])
    };
  })
}

let packModule ~rest i = match i with
  | Pstr_type (_, [{ ptype_kind; ptype_name }]) -> match ptype_kind with
    | Ptype_record (labels) -> [
      (create_object_module ~rest) ptype_name labels;
      (create_schema_config_module ~rest) ptype_name labels
    ]

let create_structure_schema ~rest root items = List.concat_map (packModule ~rest) items

let createModule old_struture_items structure_items =
  let root = structure_items |> List.rev |> List.hd in
  Mod.mk (
    Pmod_structure (
      List.append old_struture_items (create_structure_schema ~rest: old_struture_items root structure_items)
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

let () = Driver.register ~name:"re_schema_form" (module OCaml_410) test_mapper