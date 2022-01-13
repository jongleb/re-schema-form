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
  ~customPrimitives: option<PrimitiveWidget.customWidgets>=?,
  ~uiSchema: module(FieldUiSchema with type t = 'k),
) => {
  let content = <SchemaRenderImpl key="formRenderImpl" field=schema onChange formData uiSchema />
  let customWidgets = Belt_Option.getWithDefault(customPrimitives, PrimitiveWidget.defaultValue)
  <PrimitiveWidget.Provider value=customWidgets>
    <FieldTemplateContext.Provider value=fieldTemplate>
      {switch objectFieldTemplate {
      | Some(value) =>
        <ObjectFieldTemplateContext.Provider value> {content} </ObjectFieldTemplateContext.Provider>
      | _ => content
      }}
    </FieldTemplateContext.Provider>
  </PrimitiveWidget.Provider>
}
