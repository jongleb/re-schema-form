open UiSchema

module type Field = {
  type t
  type r
  let get: r => t
  let set: (r, t) => r
}

type obj = Obj
type arr = Arr
type nullable = Nullable

type rec primitive<'t> =
  | SInt: primitive<int>
  | SFloat: primitive<float>
  | SString: primitive<string>
  | SBool: primitive<bool>

type rec t<'t, 'r, _, 'm> =
  | Primitive(primitive<'t>): t<primitive<'t>, 'r, 't, 'm>
  | SObject(array<schemaListItem<'t, 'm>>): t<obj, 'r, 't, 'm>
  | SArr(t<'k, array<'t>, 't, 'm>, module(FieldUiSchema with type t = 't)): t<
      arr,
      'r,
      array<'t>,
      'm,
    >
  | SNull(t<'k, option<'t>, 't, 'm>, module(FieldUiSchema with type t = 't)): t<
      nullable,
      'r,
      option<'t>,
      'm,
    >

and schemaListItem<'t, 'm> =
  | SchemaListItem(
      t<'s, 't, 'k, 'm>,
      module(Field with type t = 'k and type r = 't),
      module(FieldUiSchema with type t = 'k),
      option<'m>,
    ): schemaListItem<'t, 'm>
