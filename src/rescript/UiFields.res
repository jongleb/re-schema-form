module type UiField = {
  type t
  @react.component
  let make: (~value: t, ~onChange: t => unit, ~children: React.element) => React.element
}

module type FieldTemplate = {
  @react.component
  let make: (~value: 't, ~onChange: 't => unit, ~children: React.element) => React.element
}

module FieldTemplateContext = {
  let context: React.Context.t<option<module(FieldTemplate)>> = React.createContext(None)

  module Provider = {
    let provider = React.Context.provider(context)

    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}