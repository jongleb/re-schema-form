open MutualTypes
open Schema
open UiFields
open Array_render_props

module Make = (Render: SchemaRender) => {
  type props = {
    wrapped: Any.t
  }

  let make = React.memo((props: props) => {
    let { wrapped: Any.Any_props(props) } = props
    let SArr(schema, uiSchema) = props.field
    let mapToElement = Js.Array.mapi((data, i) => {
      let onChange = upd =>
        props.formData |> Js.Array.mapi((ci, ii) => ii == i ? upd : ci) |> props.onChange
      <Render
        key={Belt_Int.toString(i)}
        wrapped=Any_props({
          onChange,
          uiSchema,
          field: schema,
          meta: props.meta,
          fieldTemplate: props.fieldTemplate,
          formData: data
        })
      />
    })
    <div> {props.formData |> mapToElement |> React.array} </div>
  })
}
