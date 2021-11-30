open Schema

@react.component
let make = (~field: schemaElement<obj, 'r, 'k, 'm>, ~onChange: 'k => (), ~formData: 'k) => {
    let SchemaElement(
      schema,
      _,
      uiSchema,
      _,
    ) = field
    <SchemaRender.SchemaRender field=schema onChange formData uiSchema />
}