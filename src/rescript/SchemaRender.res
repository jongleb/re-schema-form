open MutualTypes
open Schema_render_props

module Make = (Render: SwitchRender): SchemaRender => {

  type props = {
    wrapped: Any.t
  }

  let make =
    React.memo((props: props) => {
      let { wrapped: Any.Any_props(props) } = props
      let module(UiSchema) = props.uiSchema
      let switchRender =
        <Render
          wrapped=Switch_render_props.Any.Any_props({
             field:props.field,
             onChange:props.onChange,
             formData:props.formData,
             widget:UiSchema.widget,
             meta:props.meta,
             fieldTemplate:props.fieldTemplate
          })
        />
      let withUiField = switch UiSchema.field {
      | Some(module(UiField)) =>
        <UiField value=props.formData onChange=props.onChange> {switchRender} </UiField>
      | _ => switchRender
      }
      switch props.fieldTemplate {
      | Some(module(Field)) =>
        <Field value=props.formData onChange=props.onChange meta=props.meta> {withUiField} </Field>
      | _ => withUiField
      }
    })
  let () = React.setDisplayName(make, "SchemaRender")
}