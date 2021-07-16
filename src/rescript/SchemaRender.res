module type FieldRender = {
  type t
  @react.component
  let make: (~value: t, ~onChange: t => unit) => React.element
}

module type FieldWrapRender = {
  type t
  @react.component
  let make: (~meta: t, ~children: React.element) => React.element
}

module rec Schema_object: {
  type rec schema_number<'t> =
    | Schema_number_int: schema_number<int>
    | Schema_number_float: schema_number<float>

  type rec schema<'t, 'field, 'm> =
    | Schema_string('field): schema<string, 'field, 'm>
    | Schema_number('field, schema_number<'t>): schema<'t, 'field, 'm>
    | Schema_boolean('field): schema<bool, 'field, 'm>
    | Schema_object(
        ('field, module(Schema_object.Schema_config with type t = 't and type m = 'm)),
      ): schema<'t, 'field, 'm>

  module type Object = {
    type t
    type m
    type field<_>

    type rec field_wrap =
      | Mk_field(schema<'a, field<'a>, m>, m): field_wrap
      | Mk_nullable_field(schema<'a, field<option<'a>>, m>, m): field_wrap
      | Mk_array_field(schema<'a, field<array<'a>>, m>, m): field_wrap

    let schema: array<field_wrap>
    let get: (t, field<'a>) => 'a
    let set: (t, field<'a>, 'a) => t
  }

  module type Schema_config = {
    include Object

    type rec field_render =
      Mk_field_render((field<'a>, module(FieldRender with type t = 'a))): field_render

    let get_field_render: field<'a> => option<module(FieldRender with type t = 'a)>
  }
} = Schema_object

open Schema_object

module TextInputDefaultRender = {
  type t = string
  @react.component
  let make = (~value: t, ~onChange: string => unit) => {
    let onChange = e => ReactEvent.Form.target(e)["value"] |> onChange
    <input type_="text" value onChange />
  }
}

module ArrayTextInputDefaultRender = {
  type t = array<string>
  @react.component
  let make = (~value: t, ~onChange: t => unit) => {
    let onChange = (i, v) => value |> Array.mapi((ci, ii) => ci == i ? v : ii) |> onChange
    let mapped = Array.mapi((i, ii) => {
      let onChange = e => {
        let val = ReactEvent.Form.target(e)["value"]
        onChange(i, val)
      }
      <input type_="text" value=ii onChange />
    })
    value |> mapped |> React.array
  }
}

module ArrayNumberIntInputDefaultRender = {
  type t = array<int>
  @react.component
  let make = (~value: t, ~onChange: t => unit) => {
    let onChange = (i, v) => value |> Array.mapi((ci, ii) => ci == i ? v : ii) |> onChange
    let mapped = Array.mapi((i, ii) => {
      let onChange = e => {
        let val = ReactEvent.Form.target(e)["valueAsNumber"]
        onChange(i, val)
      }
      <input type_="number" value={Belt.Int.toString(ii)} onChange />
    })
    value |> mapped |> React.array
  }
}

module ArrayNumberFloatInputDefaultRender = {
  type t = array<float>
  @react.component
  let make = (~value: t, ~onChange: t => unit) => {
    let onChange = (i, v) => value |> Array.mapi((ci, ii) => ci == i ? v : ii) |> onChange
    let mapped = Array.mapi((i, ii) => {
      let onChange = e => {
        let val = ReactEvent.Form.target(e)["valueAsNumber"]
        onChange(i, val)
      }
      <input type_="number" value={Belt.Float.toString(ii)} onChange />
    })
    value |> mapped |> React.array
  }
}

module ArrayBoolInputDefaultRender = {
  type t = array<bool>
  @react.component
  let make = (~value: t, ~onChange: t => unit) => {
    let onChange = (i, v) => value |> Array.mapi((ci, ii) => ci == i ? v : ii) |> onChange
    let mapped = Array.mapi((i, ii) => {
      let onChange = e => {
        let val = ReactEvent.Form.target(e)["checked"]
        onChange(i, val)
      }
      <input type_="checkbox" checked=ii onChange />
    })
    value |> mapped |> React.array
  }
}

module OptionTextInputDefaultRender = {
  type t = option<string>
  @react.component
  let make = (~value: t, ~onChange: t => unit) => {
    let onChange = e => ReactEvent.Form.target(e)["value"] |> onChange
    <input type_="text" value={Belt.Option.getWithDefault(value, "")} onChange />
  }
}

module OptionNumberIntInputDefaultRender = {
  type t = option<int>
  @react.component
  let make = (~value: t, ~onChange: t => unit) => {
    let onChange = e => ReactEvent.Form.target(e)["valueAsNumber"] |> onChange
    let inputValue = switch value {
    | Some(v) => Belt.Int.toString(v)
    | _ => ""
    }
    <input type_="number" value=inputValue onChange />
  }
}

module OptionNumberFloatInputDefaultRender = {
  type t = option<float>
  @react.component
  let make = (~value: t, ~onChange: t => unit) => {
    let onChange = e => ReactEvent.Form.target(e)["valueAsNumber"] |> onChange
    let inputValue = switch value {
    | Some(v) => Belt.Float.toString(v)
    | _ => ""
    }
    <input type_="number" value=inputValue onChange />
  }
}

module NumberIntInputDefaultRender = {
  type t = int
  @react.component
  let make = (~value: t, ~onChange: t => unit) => {
    let onChange = e => ReactEvent.Form.target(e)["valueAsNumber"] |> onChange
    <input type_="number" value={Belt.Int.toString(value)} onChange />
  }
}

module NumberFloatInputDefaultRender = {
  type t = float
  @react.component
  let make = (~value: t, ~onChange: t => unit) => {
    let onChange = e => ReactEvent.Form.target(e)["valueAsNumber"] |> onChange
    <input type_="number" value={Belt.Float.toString(value)} onChange />
  }
}

module BoolInputDefaultRender = {
  type t = bool
  @react.component
  let make = (~value: t, ~onChange: t => unit) => {
    let onChange = e => ReactEvent.Form.target(e)["checked"] |> onChange
    <input type_="checkbox" checked=value onChange />
  }
}

module OptionBoolInputDefaultRender = {
  type t = option<bool>
  @react.component
  let make = (~value: t, ~onChange: t => unit) => {
    let onChange = e => ReactEvent.Form.target(e)["checked"] |> onChange
    <input type_="checkbox" checked={Belt.Option.getWithDefault(value, false)} onChange />
  }
}

type rec render_number_field<_> =
  | NumberIntRender: render_number_field<int>
  | NumberFloatRender: render_number_field<float>

type rec render_field<'t> =
  | NumberRender(render_number_field<'t>): render_field<'t>
  | TextRender: render_field<string>
  | BoolRender: render_field<bool>
  | OptionTextRender: render_field<option<string>>
  | OptionNumberRender(render_number_field<'t>): render_field<option<'t>>
  | OptionBoolRender: render_field<option<bool>>
  | ArrayTextRender: render_field<array<string>>
  | ArrayNumberRender(render_number_field<'t>): render_field<array<'t>>
  | ArrayBoolRender: render_field<array<bool>>

type common_field_wrap =
  | FieldWrap
  | NullableFieldWrap
  | ArrayFieldWrap
  | ObjectFieldWrap

type field_wrappers<'m> = array<(common_field_wrap, module(FieldWrapRender with type t = 'm))>

type rec render_field_wrap =
  MkRenderFieldByType(render_field<'a>, module(FieldRender with type t = 'a)): render_field_wrap

type renders = list<render_field_wrap>

type rec eq<_, _> = Eq: eq<'a, 'a>

let schema_render:
  type a b. (
    ~renders: renders,
    ~field_wrappers: field_wrappers<b>,
    ~onChange: a => unit,
    a,
    module(Schema_config with type t = a and type m = b),
  ) => React.element =
  (~renders, ~field_wrappers, ~onChange, form_data, schema) => {
    let module(DefaultFieldWrapRender: FieldWrapRender with type t = b) = module(
      {
        type t = b
        @react.component
        let make = (~meta, ~children: React.element) => <div> {children} </div>
      }
    )
    let rec iterate_schema_render:
      type a. (
        ~onChange: a => unit,
        a,
        module(Schema_config with type t = a and type m = b),
      ) => React.element =
      (~onChange, form_data: a, module(Schema: Schema_config with type t = a and type m = b)) => {
        let handle_object_field:
          type f. (
            (Schema.field<f>, module(Schema_config with type t = f and type m = b))
          ) => React.element =
          ((field, m)) => {
            let next_data = Schema.get(form_data, field)
            let next_on_change = upd => onChange(Schema.set(form_data, field, upd))
            iterate_schema_render(next_data, m, ~onChange=next_on_change)
          }
        let getSchemaRenderComponent:
          type t. (
            ~defaultRender: module(FieldRender with type t = t),
            ~renderField: render_field<t>,
            ~schemaField: Schema.field<t>,
          ) => module(FieldRender with type t = t) =
          (~defaultRender, ~renderField, ~schemaField) => {
            let concrete_field: option<
              module(FieldRender with type t = t),
            > = Schema.get_field_render(schemaField)
            let rec loop = l =>
              switch l {
              | list{} => defaultRender
              | list{MkRenderFieldByType(t, c), ...xs} => {
                  let result: option<module(FieldRender with type t = t)> = switch (
                    t,
                    renderField,
                  ) {
                  | (TextRender, TextRender) => Some(c)
                  | (NumberRender(NumberIntRender), NumberRender(NumberIntRender)) => Some(c)
                  | (NumberRender(NumberFloatRender), NumberRender(NumberFloatRender)) => Some(c)
                  | (BoolRender, BoolRender) => Some(c)
                  | (OptionBoolRender, OptionBoolRender) => Some(c)
                  | (OptionNumberRender(NumberIntRender), OptionNumberRender(NumberIntRender)) =>
                    Some(c)
                  | (
                      OptionNumberRender(NumberFloatRender),
                      OptionNumberRender(NumberFloatRender),
                    ) =>
                    Some(c)
                  | (OptionTextRender, OptionTextRender) => Some(c)
                  | _ => None
                  }
                  switch (concrete_field, result) {
                  | (Some(c), _) => c
                  | (_, Some(c)) => c
                  | _ => loop(xs)
                  }
                }
              }
            loop(renders)
          }
        let getSchemaRender:
          type t. (
            ~value: t,
            ~defaultRender: module(FieldRender with type t = t),
            ~onChange: t => unit,
            ~renderField: render_field<t>,
            ~schemaField: Schema.field<t>,
          ) => React.element =
          (~value, ~defaultRender, ~onChange, ~renderField, ~schemaField) => {
            let module(Component: FieldRender with type t = t) = getSchemaRenderComponent(
              ~defaultRender,
              ~renderField,
              ~schemaField,
            )
            <Component onChange value />
          }
        let createSchemaField:
          type t. (
            ~schemaField: Schema.field<t>,
            ~defaultRender: module(FieldRender with type t = t),
            ~renderField: render_field<t>,
          ) => React.element =
          (~schemaField, ~defaultRender, ~renderField) => {
            let value = Schema.get(form_data, schemaField)
            let onChange = e => Schema.set(form_data, schemaField, e) |> onChange
            getSchemaRender(~value, ~onChange, ~defaultRender, ~renderField, ~schemaField)
          }

        let option_field_wrapper = Belt.Array.getBy(field_wrappers, ((w, _)) => w == FieldWrap)

        let (
          _,
          module(FieldWrapResolved: FieldWrapRender with type t = b),
        ) = Belt_Option.getWithDefault(
          option_field_wrapper,
          (FieldWrap, module(DefaultFieldWrapRender: FieldWrapRender with type t = b)),
        )

        let handle_item = i =>
          switch i {
          | Schema.Mk_field(Schema_string(s), meta) => <FieldWrapResolved meta>
              {createSchemaField(
                ~schemaField=s,
                ~defaultRender=module(TextInputDefaultRender),
                ~renderField=TextRender,
              )}
            </FieldWrapResolved>
          | Schema.Mk_nullable_field(Schema_string(s), meta) => 
            <FieldWrapResolved meta>
                {createSchemaField(
                  ~schemaField=s,
                  ~defaultRender=module(OptionTextInputDefaultRender),
                  ~renderField=OptionTextRender,
              )}
              </FieldWrapResolved>
          | Schema.Mk_array_field(Schema_string(s), _) => createSchemaField(
              ~schemaField=s,
              ~defaultRender=module(ArrayTextInputDefaultRender),
              ~renderField=ArrayTextRender,
            )
          | Schema.Mk_field(Schema_number(n, Schema_number_int), _) => createSchemaField(
              ~schemaField=n,
              ~defaultRender=module(NumberIntInputDefaultRender),
              ~renderField=NumberRender(NumberIntRender),
            )
          | Schema.Mk_nullable_field(Schema_number(n, Schema_number_int), _) => createSchemaField(
              ~schemaField=n,
              ~defaultRender=module(OptionNumberIntInputDefaultRender),
              ~renderField=OptionNumberRender(NumberIntRender),
            )
          | Schema.Mk_array_field(Schema_number(n, Schema_number_int), _) => createSchemaField(
              ~schemaField=n,
              ~defaultRender=module(ArrayNumberIntInputDefaultRender),
              ~renderField=ArrayNumberRender(NumberIntRender),
            )
          | Schema.Mk_field(Schema_number(n, Schema_number_float), _) => createSchemaField(
              ~schemaField=n,
              ~defaultRender=module(NumberFloatInputDefaultRender),
              ~renderField=NumberRender(NumberFloatRender),
            )
          | Schema.Mk_nullable_field(Schema_number(n, Schema_number_float), _) => createSchemaField(
              ~schemaField=n,
              ~defaultRender=module(OptionNumberFloatInputDefaultRender),
              ~renderField=OptionNumberRender(NumberFloatRender),
            )
          | Schema.Mk_array_field(Schema_number(n, Schema_number_float), _) => createSchemaField(
              ~schemaField=n,
              ~defaultRender=module(ArrayNumberFloatInputDefaultRender),
              ~renderField=ArrayNumberRender(NumberFloatRender),
            )
          | Schema.Mk_field(Schema_boolean(b), _) => createSchemaField(
              ~schemaField=b,
              ~defaultRender=module(BoolInputDefaultRender),
              ~renderField=BoolRender,
            )
          | Schema.Mk_nullable_field(Schema_boolean(b), _) => createSchemaField(
              ~schemaField=b,
              ~defaultRender=module(OptionBoolInputDefaultRender),
              ~renderField=OptionBoolRender,
            )
          | Schema.Mk_array_field(Schema_boolean(b), _) => createSchemaField(
              ~schemaField=b,
              ~defaultRender=module(ArrayBoolInputDefaultRender),
              ~renderField=ArrayBoolRender,
            )
          | Schema.Mk_nullable_field(Schema_object(_), _) => React.null
          | Schema.Mk_array_field(Schema_object(_), _) => React.null
          | Schema.Mk_field(Schema_object(o), _) => <div
              style={ReactDOM.Style.make(~marginTop="20px", ~marginLeft="40px", ())}>
              {handle_object_field(o)}
            </div>
          }
        let items = Belt.Array.mapWithIndex(Schema.schema, (i, ii) => {
          <div key={Belt.Int.toString(i)}> {handle_item(ii)} </div>
        })
        <div> {React.array(items)} </div>
      }
    iterate_schema_render(~onChange, form_data, schema)
  }

@react.component
let make = (
  ~schema: module(Schema_config with type t = 'a and type m = 'b),
  ~form_data: 'a,
  ~onChange: 'a => unit,
  ~renders: renders,
  ~field_wrappers: field_wrappers<'b>,
) => <div> {schema_render(form_data, schema, ~renders, ~onChange, ~field_wrappers)} </div>