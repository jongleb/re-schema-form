open Migrate_parsetree;
open Ast_410;
open Ast_mapper;
open Asttypes;
open Parsetree;
open Ast_helper;
open Schema_render_base;

let annotationName = "schema";
let getAttributeByName = (attributes: list(attribute), name) => {
  let filtered =
    attributes |> List.filter(({attr_name: {txt, _},_}) => txt == name);

  switch (filtered) {
  | [] => Ok(None)
  | [attribute] => Ok(Some(attribute))
  | _ => Error("Too many occurrences of \"" ++ name ++ "\" attribute")
  };
};

type generatorSettings = {lenses: bool};
let getSettingsFromAttributes = ( attributes: list(attribute) ) =>
  switch (getAttributeByName(attributes, annotationName)) {
  | Ok(Some(_)) => Ok(Some({lenses: true}))
  | Ok(None) => Ok(None)
  | Error(_) as e => e
  };

let fail = (loc, message) =>
    Location.error(~loc, message)
    |> (v) => Location.Error(v)
    |> raise;

let loc = Location.none;
let createSetLens = (~typeName, ~gadtFieldName, ~prefix="", ~fields, ()) => {
  let cases =
    List.map(
      field => {
        Ast_helper.Exp.case(
          Ast_helper.Pat.construct(
            {loc, txt: Lident(String.capitalize_ascii(field.pld_name.txt))},
            None,
          ),
          Ast_helper.Exp.record(
            [({loc, txt: Lident(field.pld_name.txt)}, [%expr value])],
            // Spread not needed when there is only one field in the type.
            // So we avoid the "redundant with" warning
            List.length(fields) > 1 ? Some([%expr values]) : None,
          ),
        )
      },
      fields,
    );

  let recordType =
    Ast_helper.Typ.mk(Ptyp_constr({txt: Lident(typeName), loc}, []));

  let gadtTypePoly =
    Ast_helper.Typ.mk(
      Ptyp_constr({txt: Lident(gadtFieldName), loc}, [[%type: 'value]]),
    );

  let gadtTypeLocal =
    Ast_helper.Typ.mk(
      Ptyp_constr({txt: Lident(gadtFieldName), loc}, [[%type: value]]),
    );

  let typeDefinition =
    Ast_helper.Typ.poly(
      [{txt: "value", loc}],
      [%type: ([%t recordType], [%t gadtTypePoly], 'value) => [%t recordType]],
    )
    |> Ast_helper.Typ.force_poly;

  let typeDefinitionFilledWithPolyLocalType = [%type:
    ([%t recordType], [%t gadtTypeLocal], value) => [%t recordType]
  ];

  let patMatch =
    Ast_helper.Exp.mk(
      Pexp_match(
        Ast_helper.Exp.mk(Pexp_ident({txt: Lident("field"), loc})),
        cases,
      ),
    );

  // Properly applying type constraints for the poly local abstract type
  // https://caml.inria.fr/pub/docs/manual-ocaml/locallyabstract.html#p:polymorpic-locally-abstract
  let body = [%expr (values, field, value) => [%e patMatch]];
  let fnName = Ast_helper.Pat.var({txt: prefix ++ "set", loc});
  let pat = Ast_helper.Pat.constraint_(fnName, typeDefinition);
  let body =
    Ast_helper.Exp.constraint_(body, typeDefinitionFilledWithPolyLocalType);

  [%stri let [%p pat] = (type value) => [%e body]];
};

let createGetLens = (~typeName, ~gadtFieldName, ~prefix="", ~fields, ()) => {
  let cases =
    List.map(
      field => {
        Ast_helper.Exp.case(
          Ast_helper.Pat.construct(
            {loc, txt: Lident(String.capitalize_ascii(field.pld_name.txt))},
            None,
          ),
          Ast_helper.Exp.field(
            [%expr values],
            {loc, txt: Lident(field.pld_name.txt)},
          ),
        )
      },
      fields,
    );

  let recordType =
    Ast_helper.Typ.mk(Ptyp_constr({txt: Lident(typeName), loc}, []));

  let gadtTypePoly =
    Ast_helper.Typ.mk(
      Ptyp_constr({txt: Lident(gadtFieldName), loc}, [[%type: 'value]]),
    );

  let gadtTypeLocal =
    Ast_helper.Typ.mk(
      Ptyp_constr({txt: Lident(gadtFieldName), loc}, [[%type: value]]),
    );

  let typeDefinition =
    Ast_helper.Typ.poly(
      [{txt: "value", loc}],
      [%type: ([%t recordType], [%t gadtTypePoly]) => 'value],
    )
    |> Ast_helper.Typ.force_poly;

  let typeDefinitionFilledWithPolyLocalType = [%type:
    ([%t recordType], [%t gadtTypeLocal]) => value
  ];

  let patMatch =
    Ast_helper.Exp.mk(
      Pexp_match(
        Ast_helper.Exp.mk(Pexp_ident({txt: Lident("field"), loc})),
        cases,
      ),
    );

  // Properly applying type constraints for the poly local abstract type
  // https://caml.inria.fr/pub/docs/manual-ocaml/locallyabstract.html#p:polymorpic-locally-abstract
  let body = [%expr (values, field) => [%e patMatch]];
  let fnName = Ast_helper.Pat.var({txt: prefix ++ "get", loc});

  let pat = Ast_helper.Pat.constraint_(fnName, typeDefinition);
  let body =
    Ast_helper.Exp.constraint_(body, typeDefinitionFilledWithPolyLocalType);

  [%stri let [%p pat] = (type value) => [%e body]];
};

let createGadt = (~gadtFieldName, ~fields) => {
  pstr_loc: Location.none,
  pstr_desc:
    Pstr_type(
      Recursive,
      [
        {
          ptype_loc: Location.none,
          ptype_attributes: [],
          ptype_name: {
            txt: gadtFieldName,
            loc: Location.none,
          },
          ptype_params: [
            (
              {
                ptyp_loc_stack: [],
                ptyp_desc: Ptyp_any,
                ptyp_loc: Location.none,
                ptyp_attributes: [],
              },
              Invariant,
            ),
          ],
          ptype_cstrs: [],
          ptype_kind:
            Ptype_variant(
              List.map(
                field =>
                  {
                    pcd_loc: Location.none,
                    pcd_attributes: [],
                    pcd_name: {
                      txt: String.capitalize_ascii(field.pld_name.txt),
                      loc: Location.none,
                    },
                    pcd_args: Pcstr_tuple([]),
                    pcd_res:
                      Some({
                        ptyp_loc_stack: [],
                        ptyp_loc: Location.none,
                        ptyp_attributes: [],
                        ptyp_desc:
                          Ptyp_constr(
                            {txt: Lident(gadtFieldName), loc: Location.none},
                            [
                              {
                                ptyp_desc: field.pld_type.ptyp_desc,
                                ptyp_loc_stack: [],
                                ptyp_loc: Location.none,
                                ptyp_attributes: [],
                              },
                            ],
                          ),
                      }),
                  },
                fields,
              ),
            ),
          ptype_private: Public,
          ptype_manifest: None,
        },
      ],
    ),
};

let createStructureLenses =
    (~typeName, ~gadtFieldName, ~prefix=?, ~fields, ()) => {
  [
    createGadt(~gadtFieldName, ~fields),
    createGetLens(~typeName, ~gadtFieldName, ~prefix?, ~fields, ()),
    createSetLens(~typeName, ~gadtFieldName, ~prefix?, ~fields, ()),
  ];
};

let getStructureName = ({ pstr_desc }: structure_item) => {
  switch pstr_desc {
    | Pstr_type(_, [{ ptype_name }]) => ptype_name.txt
    | _ => Location.raise_errorf("Other structure name is not supported")
  }
}

let getTypeDeclarations = ({ pstr_desc }) => {
  switch pstr_desc {
    | Pstr_type(_, [{ ptype_kind }]) => 
      switch ptype_kind {
        | Ptype_record(declarations) => declarations
        | _ => Location.raise_errorf("Use only simple types");
      }
    | _  => Location.raise_errorf("Use only simple types");
  }
}

let parseSimpleType = (l: core_type) => {
    switch l {
      | [%type: int] => Some([%expr Schema.Number])
      | [%type: float] => Some([%expr Schema.Number])
      | [%type: string] => Some([%expr Schema.String])
      | [%type: bool] => Some([%expr Schema.Boolean])
      // List.t([%t? t])recript 
      | [%type: List.t([%t? t])] => Some([%expr Schema.Array])
      | [%type: list([%t? t])] => Some([%expr Schema.Array])
      | _ => None
    }
  }

let createStructureSchema2 = (root: structure_item, structure_items: structure) => {
  let tryParseAsUserType = (l: core_type) => {
    let typeName = switch l.ptyp_desc {
      | Ptyp_constr({ txt: Longident.Lident(li) }, _) => li
      | _ => Location.raise_errorf("Other structure %s ptyp_desc is not supported", Ppxlib.string_of_core_type(l))
    };
    let item = List.find_opt(i => getStructureName(i) == typeName, structure_items);
    switch item {
      | Some (i) => i
      | _ => Location.raise_errorf("Other structure %s is not supported", typeName)
    };
  }

  let rec createSchemaType = ({ pld_type }) => {
    switch pld_type.ptyp_desc {
      | Ptyp_constr(l, _) => {
          switch (parseSimpleType(pld_type)) {
            | Some(s) => s
            | None => pld_type |> tryParseAsUserType |> createObject
          }
        }
      | _ =>  Location.raise_errorf("Use only simple types");
    }
  }
  and createObject = (obj) => {
    let arr = obj 
      |> getTypeDeclarations 
      |> List.map(createSchemaType) 
      |> Ast_helper.Exp.array;
    [%expr Schema.Object([%e arr])]  
  }

  let result = createObject(root);

  [%str
    let schema = [%e result]
  ]
}

let createModule = (~typeDef, ~typeName, ~fields) =>
  Mod.mk(
    Pmod_structure([
      typeDef,
      ...createStructureLenses(
           ~typeName,
           ~gadtFieldName="field",
           ~fields,
           (),
         ),
    ]),
  );

let createModule2 = (structure_items: structure) => {
  let root = structure_items |> List.rev |> List.hd;
  Mod.mk(
    Pmod_structure(
      createStructureSchema2(root, structure_items)
    ),
  )
};  

// Heavily borrowed from Decco's code
module StructureMapper = {
  let mapTypeDecl = decl => {
    let {
      ptype_attributes,
      ptype_name: {txt: typeName, _},
      ptype_manifest,
      ptype_loc,
      ptype_kind,
      _,
    } = decl;

    switch (getSettingsFromAttributes(ptype_attributes)) {
    | Ok(Some({lenses: true})) =>
      switch (ptype_manifest, ptype_kind) {
      | (None, Ptype_abstract) =>
        fail(ptype_loc, "Can't generate lenses for unspecified type")
      | (None, Ptype_record(fields)) =>
        createStructureLenses(
          ~typeName,
          ~gadtFieldName=typeName ++ "_" ++ "field",
          ~prefix=typeName ++ "_",
          ~fields,
          (),
        )
      | _ => fail(ptype_loc, "This type is not handled by lenses-ppx")
      }
    | Ok(Some({lenses: false}))
    | Ok(None) => []
    | Error(s) => fail(ptype_loc, s)
    };
  };
  let mapStructureItem = (mapper, {pstr_desc, _} as structureItem) =>
    switch (pstr_desc) {
    | Pstr_type(_recFlag, decls) =>
      let valueBindings = decls |> List.map(mapTypeDecl) |> List.concat;
      [mapper.structure_item(mapper, structureItem)]
      @ (List.length(valueBindings) > 0 ? valueBindings : []);

    | _ => [mapper.structure_item(mapper, structureItem)]
    };
  let mapStructure = (mapper, structure) =>
    structure |> List.map(mapStructureItem(mapper)) |> List.flatten;
};

let lensesMapper = (_, _) => {
  ...default_mapper,
  structure: StructureMapper.mapStructure,
  module_expr: (mapper, expr) =>
    switch (expr) {
    | {
        pmod_desc:
          Pmod_extension((
            {txt: "schema", _},
            PStr(structure_items),
          )),
        _,
      } => createModule2(structure_items)
    | _ => default_mapper.module_expr(mapper, expr)
  },
};

let () =
  Driver.register(~name="lenses-ppx", Versions.ocaml_410, lensesMapper);