open Schema
open MutualTypes
open UiSchema

module Make = (Render: SchemaRender): ReRender => {
  type props<'t, 'r, 'k, 'm> = {
    obj: 'r,
    schema: Schema.t<'t, 'r, 'k, 'm>,
    field: module(Field with type t = 'k and type r = 'r),
    uiSchema: module(FieldUiSchema with type t = 'k),
    onChange: 'r => unit,
    key: string,
  }

  @obj
  external makeProps: (
    ~obj: 'r,
    ~schema: Schema.t<'t, 'r, 'k, 'm>,
    ~field: module(Field with type t = 'k and type r = 'r),
    ~uiSchema: module(FieldUiSchema with type t = 'k),
    ~onChange: 'r => unit,
    ~key: string,
    unit,
  ) => props<'t, 'r, 'k, 'm> = ""

  let make = (type t r k m, props: props<t, r, k, m>) => {
    let module(Field: Field with type t = k and type r = r) = props.field
    let objRef = React.useRef(props.obj)
    let onChange = React.useCallback0(val => val |> Field.set(objRef.current) |> props.onChange)
    React.useEffect2(() => {
      objRef.current = props.obj
      None
    }, (props.onChange, props.obj))
    <Render
      key="rerenderImpl"
      onChange
      uiSchema=props.uiSchema
      field=props.schema
      formData={Field.get(props.obj)}
    />
  }
  let () = React.setDisplayName(make, "ReRender")
}
