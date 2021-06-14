module type FieldRender = {
  type t
  @react.component
  let make: (~value: t, ~onChange: t => ()) => React.element
}

module rec Schema_object: {

  type rec schema_number<'t> =
    | Schema_number_int: schema_number<int>
    | Schema_number_float: schema_number<float>
    
  type rec schema<'t, 'field> =
    | Schema_string('field): schema<string, 'field>
    | Schema_number('field, schema_number<'t>): schema<'t, 'field>
    | Schema_boolean('field): schema<bool, 'field>
    | Schema_object(
        ('field, module(Schema_object.Schema_config with type t = 't)),
      ): schema<'t, 'field>;

  module type Object = {
    type t
    type field<_>

    type rec field_wrap =
        | Mk_field(schema<'a, field<'a>>): field_wrap
        | Mk_nullable_field(schema<'a, field<option<'a>>>): field_wrap
        | Mk_array_field(schema<'a, field<array<'a>>>): field_wrap;

    let schema: array<field_wrap>
    let get: (t, field<'a>) => 'a
    let set: (t, field<'a>, 'a) => t
  }

  module type Schema_config = {
    include Object

    type rec field_render =
        Mk_field_render((field<'a>, module(FieldRender with type t = 'a))): field_render

    let get_field_render: (field<'a>) => option<module(FieldRender with type t = 'a)>
  }
} = Schema_object

open Schema_object

module TextInputDefaultRender = {
  type t = string
  @react.component
  let make = (~value: t, ~onChange: string => ()) => {
    let onChange = e => ReactEvent.Form.target(e)["value"] |> onChange
    <input type_="text" value onChange />
  }
}

module OptionTextInputDefaultRender = {
  type t = option<string>
  @react.component
  let make = (~value: t, ~onChange: t => ()) => {
    let onChange = e => Some(ReactEvent.Form.target(e)["value"]) |> onChange
    <input type_="text" value=Belt.Option.getWithDefault(value, "") onChange />
  }
}

module OptionNumberIntInputDefaultRender = {
  type t = option<int>
  @react.component
  let make = (~value: t, ~onChange: t => ()) => {
    let onChange = e => Some(ReactEvent.Form.target(e)["valueAsNumber"]) |> onChange
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
  let make = (~value: t, ~onChange: t => ()) => {
    let onChange = e => Some(ReactEvent.Form.target(e)["valueAsNumber"]) |> onChange
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
  let make = (~value: t, ~onChange: t => ()) => {
    let onChange = e => ReactEvent.Form.target(e)["valueAsNumber"] |> onChange
    <input type_="number" value=Belt.Int.toString(value) onChange />
  }
}

module NumberFloatInputDefaultRender = {
  type t = float
  @react.component
  let make = (~value: t, ~onChange: t => ()) => {
    let onChange = e => ReactEvent.Form.target(e)["valueAsNumber"] |> onChange
    <input type_="number" value=Belt.Float.toString(value) onChange />
  }
}

module BoolInputDefaultRender = {
  type t = bool
  @react.component
  let make = (~value: t, ~onChange: t => ()) => {
    let onChange = e => ReactEvent.Form.target(e)["checked"] |> onChange
    <input type_="checkbox" checked=value onChange />
  }
}

module OptionBoolInputDefaultRender = {
  type t = option<bool>
  @react.component
  let make = (~value: t, ~onChange: t => ()) => {
    let onChange = e => Some(ReactEvent.Form.target(e)["checked"]) |> onChange
    <input type_="checkbox" checked=Belt.Option.getWithDefault(value, false) onChange />
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

type rec render_field_wrap = 
    | MkRenderFieldByType(render_field<'a>, (module(FieldRender with type t = 'a))) : render_field_wrap;

type renders = list<render_field_wrap>

type rec eq<_,_> = Eq: eq<'a, 'a>


let getSchemaRender: type t . (
  ~value: t,
  ~defaultRender: module(FieldRender with type t = t),
  ~onChange: t => unit,
  ~concrete_field: option<module(FieldRender with type t = t)>,
  ~renderField: render_field<t>,
  ~renders: renders
) => React.element = (
  ~value,
  ~defaultRender,
  ~onChange,
  ~concrete_field,
  ~renderField,
  ~renders,
) => {
  let module(DefaultComponent): module(FieldRender with type t = t) = defaultRender
  let rec loop = l => switch(l){
    | list{} => <DefaultComponent value onChange />
    | list{ MkRenderFieldByType(t, c), ...xs} => {
        let result: option<module(FieldRender with type t = t)>  = switch(t, renderField){
          | (TextRender, TextRender) => Some(c)
          | (NumberRender(NumberIntRender), NumberRender(NumberIntRender)) => Some(c)
          | (NumberRender(NumberFloatRender), NumberRender(NumberFloatRender)) => Some(c)
          | (BoolRender, BoolRender) => Some(c)
          | (OptionBoolRender, OptionBoolRender) => Some(c)
          | (OptionNumberRender(NumberIntRender), OptionNumberRender(NumberIntRender)) => Some(c)
          | (OptionNumberRender(NumberFloatRender), OptionNumberRender(NumberFloatRender)) => Some(c)
          | (OptionTextRender, OptionTextRender) => Some(c)
          | _ => None
      }
      switch(concrete_field, result){
        | (Some(module(Component)), _) => <Component onChange value/>
        | (_, Some(module(Component))) => <Component onChange value/>
        | _ => loop(xs)
      }
    }
  }
  loop(renders)
}

type makeSchemaFieldPayload<'t> = {
  onChange: 't => unit,
  value: 't,
}

module MakeCreateSchemaField = (Schema: Schema_config) => {
    let make: type t . (
            ~customValue: option<t>=?,
            ~customOnChange: option<t => unit>=?,
            ~onChange: Schema.t => unit,
            ~schemaField: Schema.field<t>,
            ~renderField: render_field<t>,
            ~form_data: Schema.t,
            ~defaultRender: module(FieldRender with type t = t),
            ~renders: renders
        ) => React.element =
        @react.component
        (
            ~customValue = None,
            ~customOnChange = None,
            ~onChange,
            ~schemaField,
            ~renderField,
            ~form_data,
            ~defaultRender,
            ~renders
        ) => {
            let module(DefaultComponent): module(FieldRender with type t = t) = defaultRender
            let value: t= Schema.get(form_data, schemaField)
            let onChange = (e) =>
                Schema.set(form_data, schemaField, e) |> onChange
            let concrete_field: option<module(FieldRender with type t = t)> = Schema.get_field_render(schemaField)
            getSchemaRender(
              ~value,
              ~defaultRender,
              ~onChange,
              ~concrete_field,
              ~renderField,
              ~renders
            )
        }
}


let schema_render: type a . (~renders: renders, ~onChange: ((a) => ())) => a => (module (Schema_config with type t = a)) => React.element = (~renders, ~onChange, form_data, schema) => {
    let rec iterate_schema_render: type a . 
        (~onChange: ((a) => ())) => a => (module (Schema_config with type t = a)) => React.element =
        (~onChange, form_data: a, (module(Schema)): (module(Schema_config with type t = a))) => { 

        let handle_object_field: type f . ((Schema.field<f>, (module (Schema_config with type t = f)))) => React.element = ((field, m)) => {
            let next_data = Schema.get(form_data, field)
            let next_on_change = upd => onChange(Schema.set(form_data, field, upd))
            iterate_schema_render(next_data, m, ~onChange=next_on_change)
        }

        module CreateSchemaField = MakeCreateSchemaField(Schema)

        let rec handle_item = (i) => switch (i) {
            | Schema.Mk_field (Schema_string(s)) => {
                CreateSchemaField.make(
                    ~onChange=onChange,
                    ~schemaField=s,
                    ~defaultRender=module(TextInputDefaultRender),
                    ~renderField=TextRender,
                    ~form_data=form_data,
                    ~renders=renders,
                )
            }
            | Schema.Mk_nullable_field (Schema_string(s)) => {
                CreateSchemaField.make(
                    ~onChange=onChange,
                    ~schemaField = s,
                    ~defaultRender = module(OptionTextInputDefaultRender),
                    ~renderField = OptionTextRender,
                    ~form_data=form_data,
                    ~renders=renders,
                )
            }
            | Schema.Mk_array_field (Schema_string(s)) => {
                CreateSchemaField.make(
                    ~onChange=onChange,
                    ~schemaField = s,
                    ~defaultRender = module(OptionTextInputDefaultRender),
                    ~renderField = OptionTextRender,
                    ~form_data=form_data,
                    ~renders=renders,
                )
            }
            | Schema.Mk_field (Schema_number(n, Schema_number_int)) => {
                CreateSchemaField.make(
                    ~onChange=onChange,
                    ~schemaField = n,
                    ~defaultRender = module(NumberIntInputDefaultRender),
                    ~renderField = NumberRender(NumberIntRender),
                    ~form_data=form_data,
                    ~renders=renders,
                )
            }
            | Schema.Mk_nullable_field (Schema_number(n, Schema_number_int)) => {
                CreateSchemaField.make(
                    ~onChange=onChange,
                    ~schemaField = n,
                    ~defaultRender = module(OptionNumberIntInputDefaultRender),
                    ~renderField = OptionNumberRender(NumberIntRender),
                    ~form_data=form_data,
                    ~renders=renders,
                )
            }
            | Schema.Mk_field (Schema_number(n, Schema_number_float)) => {
                CreateSchemaField.make(
                    ~onChange=onChange,
                    ~schemaField = n,
                    ~defaultRender = module(NumberFloatInputDefaultRender),
                    ~renderField = NumberRender(NumberFloatRender),
                    ~form_data=form_data,
                    ~renders=renders,
                )
            }
            | Schema.Mk_nullable_field (Schema_number(n, Schema_number_float)) => {
                CreateSchemaField.make(
                    ~onChange=onChange,
                    ~schemaField = n,
                    ~defaultRender = module(OptionNumberFloatInputDefaultRender),
                    ~renderField = OptionNumberRender(NumberFloatRender),
                    ~form_data=form_data,
                    ~renders=renders,
                )
            }
            | Schema.Mk_field (Schema_boolean(b)) => {
                CreateSchemaField.make(
                    ~onChange=onChange,
                    ~schemaField = b,
                    ~defaultRender = module(BoolInputDefaultRender),
                    ~renderField = BoolRender,
                    ~form_data=form_data,
                    ~renders=renders,
                )
            }
            | Schema.Mk_nullable_field (Schema_boolean(b)) => {
                CreateSchemaField.make(
                    ~onChange=onChange,
                    ~schemaField = b,
                    ~defaultRender = module(OptionBoolInputDefaultRender),
                    ~renderField = OptionBoolRender,
                    ~form_data=form_data,
                    ~renders=renders,
                )
            }
            | Schema.Mk_nullable_field (Schema_object(_)) => React.null
            | Schema.Mk_field (Schema_object(o)) => {
                <div style=(ReactDOM.Style.make(~marginTop="20px", ~marginLeft="40px", ()))>
                    {handle_object_field(o)}
                </div>
            }
          }
        let items = Belt.Array.mapWithIndex(Schema.schema, (i, ii) => {
            <div key={Belt.Int.toString(i)}>
                {handle_item(ii)}
            </div>
        })
        <div>
            {React.array(items)}
        </div>
    }
    iterate_schema_render(~onChange, form_data, schema)
}

@react.component
let make = (~schema: module (Schema_config with type t = 'a), ~form_data: 'a, ~onChange: ('a => ()), ~renders: renders) =>
    <div>
        { schema_render(form_data, schema, ~renders, ~onChange) }
    </div>