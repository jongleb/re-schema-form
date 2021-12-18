open Widgets
open UiFields

module type FieldUiSchema = {
  type t

  let widget: option<module(Widget with type t = t)>
  let field: option<module(UiField with type t = t)>
}
