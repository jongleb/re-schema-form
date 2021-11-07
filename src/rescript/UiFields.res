module type UiField = {
  type t

  @react.component
  let make: (~value: t, ~onChange: t => unit) => React.element
}