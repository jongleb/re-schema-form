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
  | SArr(schemaListItem<'t, 'm>): t<arr, 'r, array<'t>, 'm>
  | SNull(schemaElement<'k, 'r, 't, 'm>): t<nullable, 'r, option<'t>, 'm>

and schemaListItem<'t, 'm> =
  SchemaListItem(schemaElement<'s, 't, 'k, 'm>): schemaListItem<'t, 'm>

and schemaElement<'t, 'r, 'k, 'm> = SchemaElement(
      t<'t, 'r, 'k, 'm>,
      module(Field with type t = 'k and type r = 'r),
      module(FieldUiSchema with type t = 'k),
      option<'m>
)
