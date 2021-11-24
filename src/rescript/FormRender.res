open Schema

@react.component
let make = (~field: schemaElement<obj, 'r, 'k>, ~onChange: 'k => (), ~formData: 'k) => {
    let SchemaElement(
      schema,
      _,
      uiSchema,
    ) = field
    <SchemaRender.SchemaRender field=schema onChange formData uiSchema />
}