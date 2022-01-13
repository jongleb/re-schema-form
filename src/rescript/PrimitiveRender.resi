open Schema
open Widgets
open PrimitiveWidget

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

let make: props<'t, 'r, 'k, 'm> => React.element
