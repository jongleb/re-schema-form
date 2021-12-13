open Schema
open UiSchema
open UiFields

module type SchemaRender = {
  type props<'t, 'r, 'k, 'm> = {
    field: Schema.t<'t, 'r, 'k, 'm>,
    onChange: 'k => unit,
    formData: 'k,
    uiSchema: module(FieldUiSchema with type t = 'k),
  }

  @obj
  external makeProps: (
    ~field: Schema.t<'t, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    ~uiSchema: module(FieldUiSchema with type t = 'k),
    unit,
  ) => props<'t, 'r, 'k, 'm> = ""

  let make: props<'t, 'r, 'k, 'm> => React.element
}
module type SwitchRender = {
  type props<'t, 'r, 'k, 'm> = {
    field: Schema.t<'t, 'r, 'k, 'm>,
    onChange: 'k => unit,
    formData: 'k,
    widget: option<module(Widgets.Widget with type t = 'k)>,
  }
  @obj
  external makeProps: (
    ~field: Schema.t<'t, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    ~widget: option<module(Widgets.Widget with type t = 'k)>,
    unit,
  ) => props<'t, 'r, 'k, 'm> = ""
  let make: props<'t, 'r, 'k, 'm> => React.element
}
module type ObjectRender = {
  @react.component
  let make: (
    ~formData: 't,
    ~schema: array<schemaListItem<'t, 'm>>,
    ~onChange: 't => unit,
  ) => React.element
}
module type ReRender = {
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
  let make: props<'t, 'r, 'k, 'm> => React.element
}
module rec Impl: SchemaRender = {
  type props<'t, 'r, 'k, 'm> = {
    field: Schema.t<'t, 'r, 'k, 'm>,
    onChange: 'k => unit,
    formData: 'k,
    uiSchema: module(FieldUiSchema with type t = 'k),
  }

  @obj
  external makeProps: (
    ~field: Schema.t<'t, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    ~uiSchema: module(FieldUiSchema with type t = 'k),
    unit,
  ) => props<'t, 'r, 'k, 'm> = ""

  let make:
    type t r k m. React.component<props<t, r, k, m>> =
    (props: props<t, r, k, m>) => {
      let module(UiSchema: FieldUiSchema with type t = k) = props.uiSchema
      let switchRender =
        <SwitchRender
          field=props.field
          onChange=props.onChange
          formData=props.formData
          widget=UiSchema.widget
        />
      switch UiSchema.field {
      | Some(module(UiField: UiField with type t = k)) =>
        <UiField value=props.formData onChange=props.onChange>
          {switchRender}
        </UiField>
      | _ => switchRender
      }
    }
  let () = React.setDisplayName(make, "SchemaRender")
}
and SwitchRender: SwitchRender = {
  type props<'t, 'r, 'k, 'm> = {
    field: Schema.t<'t, 'r, 'k, 'm>,
    onChange: 'k => unit,
    formData: 'k,
    widget: option<module(Widgets.Widget with type t = 'k)>,
  }

  @obj
  external makeProps: (
    ~field: Schema.t<'t, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    ~widget: option<module(Widgets.Widget with type t = 'k)>,
    unit,
  ) => props<'t, 'r, 'k, 'm> = ""

  let make:
    type t r k m. props<t, r, k, m> => React.element =
    (props: props<t, r, k, m>) => {
      let defaultWidget = switch props.field {
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

      props.widget->Belt.Option.mapWithDefault(defaultWidget, (
        module(ComponentWidget: Widgets.Widget with type t = k),
      ) => <ComponentWidget onChange=props.onChange value=props.formData />)
    }

  let () = React.setDisplayName(make, "SwitchRender")
}
and ObjectRender: ObjectRender = {
  @react.component
  let make = (
    ~formData: 't,
    ~schema: array<schemaListItem<'t, 'm>>,
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
  let () = React.setDisplayName(make, "ObjectRender")
}
and ReRender: ReRender = {
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
    <Impl uiSchema field=schema onChange formData={Field.get(props.obj)} />
  }
  let () = React.setDisplayName(make, "ReRender")
}
module ArrayRender = {

}
