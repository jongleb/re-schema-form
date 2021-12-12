open Schema

type props<'t, 'r, 'k, 'm> = {
    obj: 'r,
    field: schemaElement<'t, 'r, 'k, 'm>,
    onChange: 'r => unit,
  }

  @obj
  external makeProps: (
    ~obj: 'r,
    ~field: schemaElement<'t, 'r, 'k, 'm>,
    ~onChange: 'r => unit,
    unit,
  ) => props<'t, 'r, 'k, 'm> = ""

  let make = (type t r k m, props: props<t, r, k, m>) => {
    let SchemaElement(
      schema,
      module(Field: Field with type t = k and type r = r),
      uiSchema,
      _,
    ) = props.field
    let objRef = React.useRef(props.obj)
    let onChange = React.useCallback0((val: k) =>
      val |> Field.set(objRef.current) |> props.onChange
    )
    React.useEffect2(() => {
      objRef.current = props.obj
      None
    }, (props.onChange, props.obj))
    <SchemaRender.SchemaRender
      uiSchema field=schema onChange formData={Field.get(props.obj)}
    />
  }
  let () = React.setDisplayName(make, "ReRender")
  