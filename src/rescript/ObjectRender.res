open MutualTypes
open Schema
open ObjectFieldTemplate
open Object_render_props

module Make = (Render: ReRender) => {
  @unboxed
  type props = {wrapped: Any.t}

  let make = React.memo((props: props) => {
    let {wrapped: Any.Any_props(props)} = props
    let module(Template: ObjectFieldTemplate) = React.useContext(ObjectFieldTemplateContext.context)
    let content = React.useMemo4(() =>
      Js.Array.mapi(
        (SchemaListItem(schema, field, uiSchema, meta), i) =>
          <Render
            key={Belt.Int.toString(i)}
            wrapped=Re_render_render_props.Any.Any_props({
              obj: props.formData,
              field,
              schema,
              uiSchema,
              meta,
              onChange: props.onChange,
              fieldTemplate: props.fieldTemplate,
            })
          />,
        props.schema,
      )
    , (props.formData, props.onChange, props.fieldTemplate, props.schema))
    <Template content formData=props.formData schema=props.schema onChange=props.onChange />
  })
  let () = React.setDisplayName(make, "ObjectRender")
}
