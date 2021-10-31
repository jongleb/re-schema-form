open Schema
open Widgets

type props<'t, 'r, 'k> = {
  field: Schema.t<primitive<'k>, 'r, 'k>,
  onChange: 'k => unit,
  formData: 'k,
}

@obj
external makeProps: (
  ~field: Schema.t<primitive<'k>, 'r, 'k>,
  ~onChange: 'k => unit,
  ~formData: 'k,
  unit,
) => props<'t, 'r, 'k> = ""

let make = (type t r k, props: props<t, r, k>) => {
  let Primitive(p) = props.field
  switch p {
  | SString => <StringWidget value=props.formData onChange=props.onChange />
  | S => expression
  }
}
