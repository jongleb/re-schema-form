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
    widget: option<module(Widgets.Widget with type t = 'k)>
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
module rec SchemaRender: SchemaRender = {
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

and SwitchRender: SwitchRender = SwitchRender

and ObjectRender: ObjectRender = ObjectRender

and ReRender: ReRender = ReRender
