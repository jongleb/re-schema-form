open MutualTypes
open Schema
open UiFields

module Make = (Render: SchemaRender) => {
  type props<'t, 'r, 'k, 'm> = {
    field: Schema.t<arr, 'r, 'k, 'm>,
    onChange: 'k => unit,
    formData: 'k,
    meta: option<'m>,
    fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
  }

  @obj
  external makeProps: (
    ~field: Schema.t<arr, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    ~meta: option<'m>,
    ~fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
    unit,
  ) => props<'t, 'r, 'k, 'm> = ""

  let make = (type t r k m, props: props<t, r, k, m>) => {
    let SArr(schema, uiSchema) = props.field
    let mapToElement = Js.Array.mapi((data, i) => {
      let onChange = upd =>
        props.formData |> Js.Array.mapi((ci, ii) => ii == i ? upd : ci) |> props.onChange
      <Render
        meta=props.meta
        key={Belt_Int.toString(i)}
        field=schema
        onChange
        formData=data
        uiSchema
        fieldTemplate=props.fieldTemplate
      />
    })
    <div> {props.formData |> mapToElement |> React.array} </div>
  }
}
