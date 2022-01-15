open MutualTypes
open Schema
open ObjectFieldTemplate
open UiFields

module Make = (Render: ReRender) => {
  type props<'t, 'm> = {
    formData: 't,
    schema: array<schemaListItem<'t, 'm>>,
    onChange: 't => unit,
    fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
  }
  @obj
  external makeProps: (
    ~formData: 't,
    ~schema: array<schemaListItem<'t, 'm>>,
    ~onChange: 't => unit,
    ~fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
    unit,
  ) => props<'t, 'm> = ""

  let make = (type t m, props: props<t, m>) => {
    let module(Template: ObjectFieldTemplate) = React.useContext(ObjectFieldTemplateContext.context)
    let content = Js.Array.mapi(
      (SchemaListItem(schema, field, uiSchema, meta), i) =>
        <Render
          key={Belt.Int.toString(i)}
          obj=props.formData
          field
          schema
          uiSchema
          meta
          onChange=props.onChange
          fieldTemplate=props.fieldTemplate
        />,
      props.schema,
    )
    <Template content formData=props.formData schema=props.schema onChange=props.onChange />
  }
  let () = React.setDisplayName(make, "ObjectRender")
}
