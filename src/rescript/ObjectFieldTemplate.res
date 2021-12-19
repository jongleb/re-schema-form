open Schema

module type ObjectFieldTemplate = {
  @react.component
  let make: (
    ~formData: 't,
    ~schema: array<schemaListItem<'t, 'm>>,
    ~onChange: 't => unit,
    ~content: array<React.element>,
  ) => React.element
}

module DefaultObjectFieldTemplate = {
  @react.component
  let make = (~formData as _, ~schema as _, ~onChange as _, ~content: array<React.element>) =>
    <div> {React.array(content)} </div>
}

module ObjectFieldTemplateContext = {
  let context: React.Context.t<module(ObjectFieldTemplate)> = React.createContext(
    module(DefaultObjectFieldTemplate: ObjectFieldTemplate),
  )

  module Provider = {
    let provider = React.Context.provider(context)

    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}
