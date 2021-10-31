open Schema

@react.component
let make = (~field: Schema.t<obj, 'r, 'k>, ~onChange: 'k => (), ~formData: 'k) => {
    <SchemaRender.SchemaRender field onChange formData />
}