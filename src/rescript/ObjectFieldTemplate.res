open Schema

module type ObjectFieldTemplate = {
  type props<'t, 'm> = {
    formData: 't,
    schema: array<schemaListItem<'t, 'm>>,
    onChange: 't => unit,
    content: array<React.element>,
  }
  let make: props<'t, 'm> => React.element
}

module DefaultObjectFieldTemplate = {
  type props<'t, 'm> = {
    formData: 't,
    schema: array<schemaListItem<'t, 'm>>,
    onChange: 't => unit,
    content: array<React.element>,
  }
  let make = (props: props<'t, 'm>) => <div> {React.array(props.content)} </div>
}

module ObjectFieldTemplateContext = {
  let context: React.Context.t<module(ObjectFieldTemplate)> = React.createContext(
    module(DefaultObjectFieldTemplate: ObjectFieldTemplate),
  )

  module Provider = {
    let make = React.Context.provider(context)
  }
}
