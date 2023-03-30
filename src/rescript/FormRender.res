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
  ~fieldTemplate: option<module(FieldTemplate with type m = 'm)>=?,
  ~objectFieldTemplate: option<module(ObjectFieldTemplate)>=?,
  ~customPrimitives: option<PrimitiveWidget.customWidgets>=?,
  ~uiSchema: module(FieldUiSchema with type t = 'k),
) => {
  let content =
    <SchemaRenderImpl
      wrapped=Any_props({
        fieldTemplate,
        meta:None,
        field:schema,
        onChange,
        formData,
        uiSchema
      })
    />
  let customWidgets = Belt_Option.getWithDefault(customPrimitives, PrimitiveWidget.defaultValue)
  <PrimitiveWidget.Provider value=customWidgets>
    {switch objectFieldTemplate {
    | Some(value) =>
      <ObjectFieldTemplateContext.Provider value> {content} </ObjectFieldTemplateContext.Provider>
    | _ => content
    }}
  </PrimitiveWidget.Provider>
}
