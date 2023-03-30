open Schema
open Widgets
open PrimitiveWidget

type props<'t, 'r, 'k, 'm> = {
  field: Schema.t<primitive<'k>, 'r, 'k, 'm>,
  onChange: 'k => unit,
  formData: 'k,
}

let make = (type t r k m, props: props<t, r, k, m>) => {
  let Primitive(p) = props.field
  let custom = React.useContext(context)
  let module(Widget: Widget with type t = k) = switch (p: primitive<k>) {
  | SString =>
    Belt_Option.getWithDefault(
      custom.stringWidget,
      module(StringWidget: Widget with type t = string),
    )
  | SInt =>
    Belt_Option.getWithDefault(custom.intWidget, module(IntWidget: Widget with type t = int))
  | SFloat =>
    Belt_Option.getWithDefault(custom.floatWidget, module(FloatWidget: Widget with type t = float))
  | SBool =>
    Belt_Option.getWithDefault(custom.boolWidget, module(BoolWidget: Widget with type t = bool))
  }
  <Widget value=props.formData onChange=props.onChange />
}

let () = React.setDisplayName(make, "PrimitiveRender")
