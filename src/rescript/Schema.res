module type Field = {
    type t
    type r
    type meta
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

  type rec t<'t, 'r, _> =
    | Primitive(primitive<'t>): t<primitive<'t>, 'r, 't>
    | SObject(array<schemaListItem<'t>>): t<obj, 'r, 't>
    | SArr(schemaElement<'k, 'r, 't>): t<arr, 'r, array<'t>>
    | SNull(schemaElement<'k, 'r, 't>): t<nullable, 'r, option<'t>>

  and schemaListItem<'t> =
    SchemaListItem(schemaElement<'s, 't, 'k>): schemaListItem<'t>
  and schemaElement<'t, 'r, 'k> =
    SchemaElement(t<'t, 'r, 'k>, module(Field with type t = 'k and type r = 'r))