module type UiField = {
  type t

  @react.component
  let make: (~value: t, ~onChange: t => unit, ~children: React.element) => React.element
}

module type FieldTemplate = {
  type m

  @react.component
  let make: (
    ~value: 't,
    ~onChange: 't => unit,
    ~children: React.element,
    ~meta: option<m>,
  ) => React.element
}
