open Schema
open MutualTypes
open Switch_render_props

module Make = (ObjRender: ObjectRender, ArrRender: ArrayRender, NullRender: NullableRender) => {
  @unboxed
  type props = {wrapped: Any.t}

  let make = React.memo((props: props) => {
    let {wrapped: Any.Any_props(props)} = props
    let defaultWidget = switch props.field {
    | SObject(arr) =>
      <ObjRender
        wrapped=Object_render_props.Any.Any_props({
          formData: props.formData,
          schema: arr,
          onChange: props.onChange,
          fieldTemplate: props.fieldTemplate,
        })
      />
    | Primitive(_) =>
      <PrimitiveRender field=props.field onChange=props.onChange formData=props.formData />
    | SArr(_) =>
      <ArrRender
        wrapped=Array_render_props.Any.Any_props({
          meta: props.meta,
          field: props.field,
          onChange: props.onChange,
          fieldTemplate: props.fieldTemplate,
          formData: props.formData,
        })
      />
    | SNull(_) =>
      <NullRender
        meta=props.meta
        field=props.field
        onChange=props.onChange
        formData=props.formData
        fieldTemplate=props.fieldTemplate
      />
    }

    props.widget->Belt.Option.mapWithDefault(defaultWidget, (module(ComponentWidget)) =>
      <ComponentWidget onChange=props.onChange value=props.formData />
    )
  })

  let () = React.setDisplayName(make, "SwitchRender")
}
