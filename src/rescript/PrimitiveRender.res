open Schema
open Widgets

type props<'t, 'r, 'k, 'm> = {
  field: Schema.t<primitive<'k>, 'r, 'k, 'm>,
  onChange: 'k => unit,
  formData: 'k,
}
@obj
external makeProps: (
  ~field: Schema.t<primitive<'k>, 'r, 'k, 'm>,
  ~onChange: 'k => unit,
  ~formData: 'k,
  unit,
) => props<'t, 'r, 'k, 'm> = ""

let make = (type t r k m, props: props<t, r, k, m>) => {
  let Primitive(p) = props.field
  let module(Widget: Widget with type t = k) = switch (p: primitive<k>) {
  | SString => module(StringWidget)
  | SInt => module(IntWidget)
  | SFloat => module(FloatWidget)
  | SBool => module(BoolWidget)
  }
  <Widget value=props.formData onChange=props.onChange />
}

let () = React.setDisplayName(make, "PrimitiveRender")