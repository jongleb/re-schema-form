open MutualTypes
open Schema
open Widgets
open UiFields

module Make = (Render: SchemaRender) => {
  type props<'t, 'r, 'k, 'm> = {
    field: Schema.t<nullable, 'r, 'k, 'm>,
    onChange: 'k => unit,
    formData: 'k,
    meta: option<'m>,
    fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
  }
  @obj
  external makeProps: (
    ~field: Schema.t<nullable, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    ~meta: option<'m>,
    ~fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
    unit,
  ) => props<'t, 'r, 'k, 'm> = ""

  let make = (type t r k m, props: props<t, r, k, m>) => {
    let SNull(schema, uiSchema) = props.field
    let onChange = e => props.onChange(Some(e))
    switch props.formData {
    | Some(data) =>
      <Render
        wrapped=Any_props({
          onChange,
          uiSchema,
          field: schema,
          meta: props.meta,
          fieldTemplate: props.fieldTemplate,
          formData: data,
        })
      />
    | _ =>
      switch schema {
      | Primitive(SString) => <StringWidget value="" onChange />
      | Primitive(SBool) => <BoolWidget value=false onChange />
      | Primitive(_) => <NumberWidget value="" onChange />
      | _ => React.null
      }
    }
  }
}
