open UiSchema
open UiFields
open Schema

module type SchemaRender = {
  type props<'t, 'r, 'k, 'm> = {
    field: Schema.t<'t, 'r, 'k, 'm>,
    onChange: 'k => unit,
    formData: 'k,
    uiSchema: module(FieldUiSchema with type t = 'k),
    meta: option<'m>,
    fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
    key: string,
  }

  @obj
  external makeProps: (
    ~field: Schema.t<'t, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    ~uiSchema: module(FieldUiSchema with type t = 'k),
    ~meta: option<'m>,
    ~fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
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
    fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
    meta: option<'m>,
  }
  @obj
  external makeProps: (
    ~field: Schema.t<'t, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    ~widget: option<module(Widgets.Widget with type t = 'k)>,
    ~fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
    ~meta: option<'m>,
    unit,
  ) => props<'t, 'r, 'k, 'm> = ""
  let make: props<'t, 'r, 'k, 'm> => React.element
}
module type ObjectRender = {
  type props<'t, 'm> = {
    formData: 't,
    schema: array<schemaListItem<'t, 'm>>,
    onChange: 't => unit,
    fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
  }
  @obj
  external makeProps: (
    ~formData: 't,
    ~schema: array<schemaListItem<'t, 'm>>,
    ~onChange: 't => unit,
    ~fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
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
    meta: option<'m>,
    fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
    key: string,
  }
  @obj
  external makeProps: (
    ~obj: 'r,
    ~schema: Schema.t<'t, 'r, 'k, 'm>,
    ~field: module(Field with type t = 'k and type r = 'r),
    ~uiSchema: module(FieldUiSchema with type t = 'k),
    ~onChange: 'r => unit,
    ~meta: option<'m>,
    ~fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
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
    meta: option<'m>,
    fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
  }
  @obj
  external makeProps: (
    ~field: Schema.t<arr, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    ~meta: option<'m>,
    ~fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
    unit,
  ) => props<'t, 'r, 'k, 'm> = ""

  let make: props<'t, 'r, 'k, 'm> => React.element
}
module type NullableRender = {
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

  let make: props<'t, 'r, 'k, 'm> => React.element
}
