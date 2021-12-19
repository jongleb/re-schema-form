open Schema
open MutualTypes

module Make = (
  ObjRender: ObjectRender,
  ArrRender: ArrayRender,
  NullRender: NullableRender
) => {
  type props<'t, 'r, 'k, 'm> = {
  field: Schema.t<'t, 'r, 'k, 'm>,
  onChange: 'k => unit,
  formData: 'k,
  widget: option<module(Widgets.Widget with type t = 'k)>,
}

@obj
external makeProps: (
  ~field: Schema.t<'t, 'r, 'k, 'm>,
  ~onChange: 'k => unit,
  ~formData: 'k,
  ~widget: option<module(Widgets.Widget with type t = 'k)>,
  unit,
) => props<'t, 'r, 'k, 'm> = ""

let make:
  type t r k m. props<t, r, k, m> => React.element =
  (props: props<t, r, k, m>) => {
    let defaultWidget = switch props.field {
    | SObject(arr) => <ObjRender formData=props.formData schema=arr onChange=props.onChange />
    | Primitive(_) =>
      <PrimitiveRender field=props.field onChange=props.onChange formData=props.formData />
    | SArr(_) => <ArrRender field=props.field onChange=props.onChange formData=props.formData />
    | SNull(_) =>
      <NullRender field=props.field onChange=props.onChange formData=props.formData />
    }

    props.widget->Belt.Option.mapWithDefault(defaultWidget, (
      module(ComponentWidget: Widgets.Widget with type t = k),
    ) => <ComponentWidget onChange=props.onChange value=props.formData />)
  }

let () = React.setDisplayName(make, "SwitchRender")

}