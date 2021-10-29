open Schema


@react.component
let make = (~formData: 't, 
    ~field: Schema.t<obj, 't, 't>, 
    ~onChange: ('t) => ()) => {
  <SchemaRender2 field onChange formData/>
} 