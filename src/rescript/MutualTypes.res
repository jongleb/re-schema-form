open UiSchema
open UiFields
open Schema

module Schema_render_props = {
  module Real_props = {
    type t<'t, 'r, 'k, 'm> = {
      field: Schema.t<'t, 'r, 'k, 'm>,
      onChange: 'k => unit,
      formData: 'k,
      uiSchema: module(FieldUiSchema with type t = 'k),
      meta: option<'m>,
      fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
    }
  }

  module Any = {
    @unboxed
    type rec t =
      | Any_props (Real_props.t<'t, 'r, 'k, 'm>) : t;
  }
}

module type SchemaRender = {
  type props = { wrapped: Schema_render_props.Any.t }

  let make: props => React.element
}

module Switch_render_props = {
  module Real_props = {
    type t<'t, 'r, 'k, 'm> = {
      field: Schema.t<'t, 'r, 'k, 'm>,
      onChange: 'k => unit,
      formData: 'k,
      widget: option<module(Widgets.Widget with type t = 'k)>,
      fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
      meta: option<'m>,
    }
  }

  module Any = {
    @unboxed
    type rec t =
      | Any_props (Real_props.t<'t, 'r, 'k, 'm>) : t;
  }
}

module type SwitchRender = {
  type props = { wrapped: Switch_render_props.Any.t }

  let make: props => React.element
}

module Object_render_props = {
  module Real_props = {
    type t<'t, 'm> = {
      formData: 't,
      schema: array<schemaListItem<'t, 'm>>,
      onChange: 't => unit,
      fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
    }
  }

  module Any = {
    @unboxed
    type rec t =
      | Any_props (Real_props.t<'t, 'm>) : t;
  }
}

module type ObjectRender = {
  type props = { wrapped: Object_render_props.Any.t }

  let make: props => React.element
}

module Re_render_render_props = {
  module Real_props = {
    type t<'t, 'r, 'k, 'm> = {
      obj: 'r,
      schema: Schema.t<'t, 'r, 'k, 'm>,
      field: module(Field with type t = 'k and type r = 'r),
      uiSchema: module(FieldUiSchema with type t = 'k),
      onChange: 'r => unit,
      meta: option<'m>,
      fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
    }
  }

  module Any = {
    @unboxed
    type rec t =
      | Any_props (Real_props.t<'t, 'r, 'k, 'm>) : t;
  }
}

module type ReRender = {
  type props = { wrapped: Re_render_render_props.Any.t }

  let make: props => React.element
}

module Array_render_props = {
  module Real_props = {
    type t<'t, 'r, 'k, 'm> = {
      field: Schema.t<arr, 'r, 'k, 'm>,
      onChange: 'k => unit,
      formData: 'k,
      meta: option<'m>,
      fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
    }
  }

  module Any = {
    @unboxed
    type rec t =
      | Any_props (Real_props.t<'t, 'r, 'k, 'm>) : t;
  }
}


module type ArrayRender = {
  type props = { wrapped: Array_render_props.Any.t }

  let make: props => React.element
}
module type NullableRender = {
  type props<'t, 'r, 'k, 'm> = {
    field: Schema.t<nullable, 'r, 'k, 'm>,
    onChange: 'k => unit,
    formData: 'k,
    meta: option<'m>,
    fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
  }

  let make: props<'t, 'r, 'k, 'm> => React.element
}
