open MutualTypes
open Schema

module Make = (Render: SchemaRender) => {
  type props<'t, 'r, 'k, 'm> = {
    field: Schema.t<arr, 'r, 'k, 'm>,
    onChange: 'k => unit,
    formData: 'k,
  }
  @obj
  external makeProps: (
    ~field: Schema.t<arr, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    unit,
  ) => props<'t, 'r, 'k, 'm> = ""

  let make = (type t r k m, props: props<t, r, k, m>) => {
    let SArr(schema, uiSchema) = props.field
    let mapToElement = Js.Array.mapi((data, i) => {
      let onChange = upd =>
        props.formData |> Js.Array.mapi((ci, ii) => ii == i ? upd : ci) |> props.onChange
      <Render key={Belt_Int.toString(i)} field=schema onChange formData=data uiSchema />
    })
    <div> {props.formData |> mapToElement |> React.array} </div>
  }
}
