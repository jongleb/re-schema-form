open Schema
open UiFields

@react.component
let make = (
  ~field: schemaElement<obj, 'r, 'k, 'm>,
  ~onChange: 'k => unit,
  ~formData: 'k,
  ~fieldTemplate: option<module(FieldTemplate)>=?,
) => {
  let SchemaElement(schema, _, uiSchema, _) = field
  <FieldTemplateContext.Provider value=fieldTemplate>
    <SchemaRender.Impl field=schema onChange formData uiSchema />
  </FieldTemplateContext.Provider>
}
