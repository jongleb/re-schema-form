open Schema

type props<'t, 'r, 'k> = {
  obj: 'r,
  field: schemaElement<'t, 'r, 'k>,
  onChange: 'r => unit,
  formData: 'k,
}

@obj
external makeProps: (
  ~obj: 'r,
  ~field: schemaElement<'t, 'r, 'k>,
  ~onChange: 'r => unit,
  ~formData: 'k,
) => props<'t, 'r, 'k> = ""

let make = (type t r k, props: props<t, r, k>) => {
  let SchemaElement(
    _,
    module(Field: Field with type t = k and type r = r),
  ) = props.field
  let objRef = React.useRef(props.obj)
  let onChange = React.useCallback0((val: k) =>
    val |> Field.set(objRef.current) |> props.onChange
  )
  React.useEffect2(() => {
    objRef.current = props.obj
    None
  }, (props.onChange, props.obj))
  2
}
