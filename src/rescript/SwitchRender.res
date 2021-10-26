open Schema

type props<'t, 'r, 'k> = {
  field: Schema.t<'t, 'r, 'k>,
  onChange: 'k => unit,
  formData: 'k,
}

@obj
external makeProps: (
  ~field: Schema.t<'t, 'r, 'k>,
  ~onChange: 'k => unit,
  ~formData: 'k,
) => props<'t, 'r, 'k> = ""

let make: type t r k. props<t, r, k> => React.element = (props: props<t, r, k>) => {
   switch props.field {
      | SObject(s, m) => <ObjectRender />
      | Primitive(p, m) => React.string("2")
      | SArr(_, _, _) => React.string("3")
      | _ => React.string("")
   }
}