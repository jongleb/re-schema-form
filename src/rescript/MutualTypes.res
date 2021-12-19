open UiSchema
open Schema

module type SchemaRender = {
  type props<'t, 'r, 'k, 'm> = {
    field: Schema.t<'t, 'r, 'k, 'm>,
    onChange: 'k => unit,
    formData: 'k,
    uiSchema: module(FieldUiSchema with type t = 'k),
    key: string,
  }

  @obj
  external makeProps: (
    ~field: Schema.t<'t, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    ~uiSchema: module(FieldUiSchema with type t = 'k),
    ~key: string,
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
module type NullableRender = {
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

  let make: props<'t, 'r, 'k, 'm> => React.element
}