open MutualTypes
open Schema
open ObjectFieldTemplate

module Make = (Render: ReRender) => {
  type props<'t, 'm> = {
    formData: 't,
    schema: array<schemaListItem<'t, 'm>>,
    onChange: 't => unit,
  }
  @obj
  external makeProps: (
    ~formData: 't,
    ~schema: array<schemaListItem<'t, 'm>>,
    ~onChange: 't => unit,
    unit,
  ) => props<'t, 'm> = ""

  let make = (type t m, props: props<t, m>) => {
    let module(Template: ObjectFieldTemplate) = React.useContext(ObjectFieldTemplateContext.context)
    let content = Js.Array.mapi(
      (SchemaListItem(schema, field, uiSchema, _), i) =>
        <Render
          key={Belt.Int.toString(i)}
          obj=props.formData
          field
          schema
          uiSchema
          onChange=props.onChange
        />,
      props.schema,
    )
    <Template content formData=props.formData schema=props.schema onChange=props.onChange />
  }
  let () = React.setDisplayName(make, "ObjectRender")
}
