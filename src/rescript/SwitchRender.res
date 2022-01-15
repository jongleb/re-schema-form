open Schema
open MutualTypes
open UiFields

module Make = (ObjRender: ObjectRender, ArrRender: ArrayRender, NullRender: NullableRender) => {
  type props<'t, 'r, 'k, 'm> = {
    field: Schema.t<'t, 'r, 'k, 'm>,
    onChange: 'k => unit,
    formData: 'k,
    widget: option<module(Widgets.Widget with type t = 'k)>,
    fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
    meta: option<'m>,
  }

  @obj
  external makeProps: (
    ~field: Schema.t<'t, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    ~widget: option<module(Widgets.Widget with type t = 'k)>,
    ~fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
    ~meta: option<'m>,
    unit,
  ) => props<'t, 'r, 'k, 'm> = ""

  let make:
    type t r k m. props<t, r, k, m> => React.element =
    (props: props<t, r, k, m>) => {
      let defaultWidget = switch props.field {
      | SObject(arr) =>
        <ObjRender
          formData=props.formData
          schema=arr
          onChange=props.onChange
          fieldTemplate=props.fieldTemplate
        />
      | Primitive(_) =>
        <PrimitiveRender field=props.field onChange=props.onChange formData=props.formData />
      | SArr(_) =>
        <ArrRender
          meta=props.meta
          field=props.field
          onChange=props.onChange
          fieldTemplate=props.fieldTemplate
          formData=props.formData
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

      props.widget->Belt.Option.mapWithDefault(defaultWidget, (
        module(ComponentWidget: Widgets.Widget with type t = k),
      ) => <ComponentWidget onChange=props.onChange value=props.formData />)
    }

  let () = React.setDisplayName(make, "SwitchRender")
}
