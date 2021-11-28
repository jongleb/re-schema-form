open Schema
open UiSchema
open UiFields

type m

module type SchemaRender = {
  type props<'t, 'r, 'k> = {
    field: Schema.t<'t, 'r, 'k>,
    onChange: 'k => unit,
    formData: 'k,
    uiSchema: module(FieldUiSchema with type t = 'k),
  }

  @obj
  external makeProps: (
    ~field: Schema.t<'t, 'r, 'k>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    ~uiSchema: module(FieldUiSchema with type t = 'k),
    unit,
  ) => props<'t, 'r, 'k> = ""

  let make: props<'t, 'r, 'k> => React.element
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
  type props<'t, 'r, 'k> = {
    field: Schema.t<'t, 'r, 'k>,
    onChange: 'k => unit,
    formData: 'k,
    uiSchema: module(FieldUiSchema with type t = 'k),
  }

  @obj
  external makeProps: (
    ~field: Schema.t<'t, 'r, 'k>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    ~uiSchema: module(FieldUiSchema with type t = 'k),
    unit,
  ) => props<'t, 'r, 'k> = ""

  let make:
    type t r k. React.component<props<t, r, k>> =
    (props: props<t, r, k>) => {
      let module(UiSchema: FieldUiSchema with type t = k) = props.uiSchema
      let switchRender =
        <SwitchRender
          field=props.field onChange=props.onChange formData=props.formData
        />
      switch UiSchema.field {
      | Some(module(UiField: UiField with type t = k)) =>
        <UiField value=props.formData onChange=props.onChange>
          {switchRender}
        </UiField>
      | _ => switchRender
      }
    }
  React.setDisplayName(make, "SchemaRender")
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
      | Primitive(_) =>
        <PrimitiveRender
          field=props.field onChange=props.onChange formData=props.formData
        />
      | SArr(_) => React.string("3")
      | _ => React.string("")
      }
    }

  React.setDisplayName(make, "SwitchRender")
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
  React.setDisplayName(make, "ObjectRender")
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
      uiSchema,
    ) = props.field
    let objRef = React.useRef(props.obj)
    let onChange = React.useCallback0((val: k) =>
      val |> Field.set(objRef.current) |> props.onChange
    )
    React.useEffect2(() => {
      objRef.current = props.obj
      None
    }, (props.onChange, props.obj))
    <SchemaRender
      uiSchema field=schema onChange formData={Field.get(props.obj)}
    />
  }
  React.setDisplayName(make, "ReRender")
}
