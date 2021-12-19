open Schema
open UiFields
open UiSchema
open ObjectFieldTemplate
open MutualImpls

@react.component
let make = (
  ~schema: Schema.t<obj, 'r, 'k, 'm>,
  ~onChange: 'k => unit,
  ~formData: 'k,
  ~fieldTemplate: option<module(FieldTemplate)>=?,
  ~objectFieldTemplate: option<module(ObjectFieldTemplate)>=?,
  ~uiSchema: module(FieldUiSchema with type t = 'k),
) => {
  let content = <SchemaRenderImpl key="formRenderImpl" field=schema onChange formData uiSchema />
  <FieldTemplateContext.Provider value=fieldTemplate>
    {switch objectFieldTemplate {
    | Some(value) =>
      <ObjectFieldTemplateContext.Provider value> {content} </ObjectFieldTemplateContext.Provider>
    | _ => content
    }}
  </FieldTemplateContext.Provider>
}
