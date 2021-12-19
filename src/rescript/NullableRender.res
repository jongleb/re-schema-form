open MutualTypes
open Schema
open Widgets

module Make = (Render: SchemaRender) => {
  type props<'t, 'r, 'k, 'm> = {
    field: Schema.t<nullable, 'r, 'k, 'm>,
    onChange: 'k => unit,
    formData: 'k,
  }
  @obj
  external makeProps: (
    ~field: Schema.t<nullable, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    unit,
  ) => props<'t, 'r, 'k, 'm> = ""

  let make = (type t r k m, props: props<t, r, k, m>) => {
    let SNull(schema, uiSchema) = props.field
    let onChange = e => props.onChange(Some(e))
    switch props.formData {
    | Some(data) => <Render key="nullableImpl" field=schema onChange formData=data uiSchema />
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
