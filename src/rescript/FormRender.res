open Schema

// type props = {
//     objectFieldTemplate: string
// }

type props<'t> = {
    formData: 't,
    field: Schema.t<obj, 't, 't>,
    onChange: ('t) => unit
};

@obj external makeProps:(
    ~formData: 't, 
    ~field: Schema.t<obj, 't, 't>, 
    ~onChange: ('t) => unit
) => props<'t> = "" 


let make = (type t, props: props<t>) => {
  let formDataRef = React.useRef(props.formData)
  let onChange = React.useCallback0((val: t) => {
    let SObject(_, module(Field): module(Field with type t = t and type r = t)) = props.field
    val |> Field.set(props.formData) |> props.onChange
  })
} 