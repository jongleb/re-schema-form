open Schema

type props<'t, 'r, 'k, 'm> = {
  field: Schema.t<primitive<'k>, 'r, 'k, 'm>,
  onChange: 'k => unit,
  formData: 'k,
}

let make: props<'t, 'r, 'k, 'm> => React.element
