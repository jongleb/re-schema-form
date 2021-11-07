open Schema
open UiSchema

@react.component
let make = (~field: Schema.t<obj, 'r, 'k>, ~onChange: 'k => (), ~formData: 'k, ~uiSchema: module(FieldUiSchema with type t = 'k)) => {
    <SchemaRender.SchemaRender field onChange formData uiSchema />
}