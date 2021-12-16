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
  type props<'t, 'm> = {
    formData: 't,
    schema: array<schemaListItem<'t, 'm>>,
    onChange: 't => unit,
  }
  @obj
  external makeProps: (
    ~formData: 't,
    ~schema: array<schemaListItem<'t, 'm>>,
    ~onChange: 't => unit,
    unit,
  ) => props<'t, 'm> = ""

  let make: props<'t, 'm> => React.element
}
module type ReRender = {
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
  let make: props<'t, 'r, 'k, 'm> => React.element
}
module type ArrayRender = {
  type props<'t, 'r, 'k, 'm> = {
    field: Schema.t<arr, 'r, 'k, 'm>,
    onChange: 'k => unit,
    formData: 'k,
  }
  @obj
  external makeProps: (
    ~field: Schema.t<arr, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
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
      let fieldTemplateContext = React.useContext(FieldTemplateContext.context)
      let switchRender =
        <SwitchRender
          field=props.field
          onChange=props.onChange
          formData=props.formData
          widget=UiSchema.widget
        />
      let withUiField = switch UiSchema.field {
      | Some(module(UiField: UiField with type t = k)) =>
        <UiField value=props.formData onChange=props.onChange>
          {switchRender}
        </UiField>
      | _ => switchRender
      }
      switch fieldTemplateContext {
      | Some(module(Field)) =>
        <Field value=props.formData onChange=props.onChange>
          {withUiField}
        </Field>
      | _ => withUiField
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
      | SArr(_) =>
        <ArrayRender
          field=props.field onChange=props.onChange formData=props.formData
        />
      | _ => React.string("")
      }

      props.widget->Belt.Option.mapWithDefault(defaultWidget, (
        module(ComponentWidget: Widgets.Widget with type t = k),
      ) => <ComponentWidget onChange=props.onChange value=props.formData />)
    }

  let () = React.setDisplayName(make, "SwitchRender")
}
and ObjectRender: ObjectRender = {
  type props<'t, 'm> = {
    formData: 't,
    schema: array<schemaListItem<'t, 'm>>,
    onChange: 't => unit,
  }
  @obj
  external makeProps: (
    ~formData: 't,
    ~schema: array<schemaListItem<'t, 'm>>,
    ~onChange: 't => unit,
    unit,
  ) => props<'t, 'm> = ""

  let make = (type t m, props: props<t, m>) => {
    <React.Fragment>
      {props.schema
      |> Js.Array.mapi((
        SchemaListItem(
          schema,
          field,
          uiSchema,
          _,
        ),
        i,
      ) => 
        <ReRender 
          key={Belt.Int.toString(i)} 
          obj=props.formData 
          field
          schema
          uiSchema
          onChange=props.onChange 
        />)
      |> React.array}
    </React.Fragment>
  }
  let () = React.setDisplayName(make, "ObjectRender")
}
and ReRender: ReRender = {
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
    let onChange = React.useCallback0((val) =>
      val |> Field.set(objRef.current) |> props.onChange
    )
    React.useEffect2(() => {
      objRef.current = props.obj
      None
    }, (props.onChange, props.obj))
    <Impl
      onChange
      uiSchema=props.uiSchema 
      field=props.schema
      formData={Field.get(props.obj)} />
  }
  let () = React.setDisplayName(make, "ReRender")
}
and ArrayRender: ArrayRender = {
  type props<'t, 'r, 'k, 'm> = {
    field: Schema.t<arr, 'r, 'k, 'm>,
    onChange: 'k => unit,
    formData: 'k,
  }
  @obj
  external makeProps: (
    ~field: Schema.t<arr, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    unit,
  ) => props<'t, 'r, 'k, 'm> = ""

  let make = (type t r k m, props: props<t, r, k, m>) => {
    let SArr(schema, _,) = props.field
    let mapToElement = Js.Array.mapi((data, i) => {
      let onChange = upd =>
        props.formData
        |> Js.Array.mapi((ci, ii) => ii == i ? upd : ci)
        |> props.onChange
      <SwitchRender field=schema onChange formData=data widget=None /> // @TODO should implement
    })
    <div> {props.formData |> mapToElement |> React.array} </div>
  }
}
