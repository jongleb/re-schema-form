open Schema
module type SchemaRender = {
  @react.component
  let make: (
    ~field: Schema.t<'t, 'r, 'k>,
    ~onChange: 'k => unit,
    ~formData: 'k,
  ) => React.element
}
module type SwitchRender = {
  type props<'t, 'r, 'k> = {
    field: Schema.t<'t, 'r, 'k>,
    onChange: 'k => unit,
    formData: 'k,
  }
  @obj
  external makeProps: (
    ~field: Schema.t<'t, 'r, 'k>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    unit,
  ) => props<'t, 'r, 'k> = ""
  let make: props<'t, 'r, 'k> => React.element
}
module type ObjectRender = {
  @react.component
  let make: (
    ~formData: 't,
    ~schema: array<schemaListItem<'t>>,
    ~onChange: 't => unit,
  ) => React.element
}
module type ReRender = {
  type props<'t, 'r, 'k> = {
    obj: 'r,
    field: schemaElement<'t, 'r, 'k>,
    onChange: 'r => unit,
  }
  @obj
  external makeProps: (
    ~obj: 'r,
    ~field: schemaElement<'t, 'r, 'k>,
    ~onChange: 'r => unit,
    unit,
  ) => props<'t, 'r, 'k> = ""
  let make: props<'t, 'r, 'k> => React.element
}
module rec SchemaRender: SchemaRender = {
  @react.component
  let make = (~field, ~onChange, ~formData) => {
    <SwitchRender field onChange formData />
  }
}
and SwitchRender: SwitchRender = {
  type props<'t, 'r, 'k> = {
    field: Schema.t<'t, 'r, 'k>,
    onChange: 'k => unit,
    formData: 'k,
  }

  @obj
  external makeProps: (
    ~field: Schema.t<'t, 'r, 'k>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    unit,
  ) => props<'t, 'r, 'k> = ""

  let make:
    type t r k. props<t, r, k> => React.element =
    (props: props<t, r, k>) => {
      switch props.field {
      | SObject(arr) =>
        <ObjectRender
          formData=props.formData schema=arr onChange=props.onChange
        />
      | Primitive(s) => React.string("2")
      | SArr(s) => React.string("3")
      | _ => React.string("")
      }
    }
}
and ObjectRender: ObjectRender = {
  @react.component
  let make = (
    ~formData: 't,
    ~schema: array<schemaListItem<'t>>,
    ~onChange: 't => unit,
  ) => {
    <React.Fragment>
      {schema
      |> Array.map((SchemaListItem(field)) =>
        <ReRender obj=formData field onChange />
      )
      |> React.array}
    </React.Fragment>
  }
}
and ReRender: ReRender = {
  type props<'t, 'r, 'k> = {
    obj: 'r,
    field: schemaElement<'t, 'r, 'k>,
    onChange: 'r => unit,
  }

  @obj
  external makeProps: (
    ~obj: 'r,
    ~field: schemaElement<'t, 'r, 'k>,
    ~onChange: 'r => unit,
    unit,
  ) => props<'t, 'r, 'k> = ""

  let make = (type t r k, props: props<t, r, k>) => {
    let SchemaElement(
      schema,
      module(Field: Field with type t = k and type r = r),
    ) = props.field
    let objRef = React.useRef(props.obj)
    let onChange = React.useCallback0((val: k) =>
      val |> Field.set(objRef.current) |> props.onChange
    )
    React.useEffect2(() => {
      objRef.current = props.obj
      None
    }, (props.onChange, props.obj))
    <SchemaRender field=schema onChange formData={Field.get(props.obj)} />
  }
}