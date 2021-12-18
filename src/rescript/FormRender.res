open Schema
open UiFields
open UiSchema

@react.component
let make = (
  ~schema: Schema.t<obj, 'r, 'k, 'm>,
  ~onChange: 'k => unit,
  ~formData: 'k,
  ~fieldTemplate: option<module(FieldTemplate)>=?,
  ~uiSchema: module(FieldUiSchema with type t = 'k),
) => {
  <FieldTemplateContext.Provider value=fieldTemplate>
    <SchemaRender.Impl key="formRenderImpl" field=schema onChange formData uiSchema />
  </FieldTemplateContext.Provider>
}
