open Schema
open MutualTypes
open UiSchema
open UiFields
open Re_render_render_props

module Make = (Render: SchemaRender): ReRender => {
  type props = {
    wrapped: Any.t
  }

  let make = React.memo((props: props) => {
    let { wrapped: Any.Any_props(props) } = props
    let module(Field) = props.field
    let objRef = React.useRef(props.obj)
    let onChange = React.useCallback0(val => val |> Field.set(objRef.current) |> props.onChange)
    React.useEffect2(() => {
      objRef.current = props.obj
      None
    }, (props.onChange, props.obj))
    <Render
      wrapped=Any_props({
        onChange,
        uiSchema: props.uiSchema,
        field: props.schema,
        meta: props.meta,
        fieldTemplate: props.fieldTemplate,
        formData: Field.get(props.obj)
      })
    />
  })
  let () = React.setDisplayName(make, "ReRender")
}
