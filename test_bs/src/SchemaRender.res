open Schema.Schema_object

module type FieldRender = {
  type t
  @react.component
  let make: (~value: t, ~onChange: t => ()) => React.element
}

module TextInputDefaultRender = {
  type t = string
  @react.component
  let make = (~value: t, ~onChange: string => ()) => {
    let onChange = e => ReactEvent.Form.target(e)["value"] |> onChange
    <input type_="text" value onChange />
  }
}

module NumberInputDefaultRender = {
  type t = int
  @react.component
  let make = (~value: t, ~onChange: t => ()) => {
    let onChange = e => ReactEvent.Form.target(e)["valueAsNumber"] |> onChange
    <input type_="number" value=Belt.Int.toString(value) onChange />
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

type rec render_field<_> =
    | NumberRender: render_field<int>
    | TextRender: render_field<string>
    | BoolRender: render_field<bool>

type rec render_field_wrap = 
    | MkRenderFieldByType((render_field<'a>, (module(FieldRender with type t = 'a)))) : render_field_wrap;

type renders = list<render_field_wrap>

let schema_render: type a . (~renders: renders, ~onChange: ((a) => ())) => a => (module (Object with type t = a)) => React.element = (~renders, ~onChange, form_data, schema) => {
    let rec iterate_schema_render: type a . 
        (~onChange: ((a) => ())) => a => (module (Object with type t = a)) => React.element =
        (~onChange, form_data: a, (module(Schema)): (module(Object with type t = a))) => { 
        let handle_object_field: type f . ((Schema.field<f>, (module (Object with type t = f)))) => React.element = ((field, m)) => {
            let next_data = Schema.get(form_data, field)
            let next_on_change = upd => onChange(Schema.set(form_data, field, upd))
            iterate_schema_render(next_data, m, ~onChange=next_on_change)
        }
        let createSchemaField: type t . (
            ~schemaField: Schema.field<t>,
            ~defaultRender: module(FieldRender with type t = t), 
            ~getRender: (render_field_wrap) => option<module(FieldRender with type t = t)>
        ) => React.element = (
            ~schemaField,
            ~defaultRender,
            ~getRender
        ) => {
            let module(DefaultComponent): module(FieldRender with type t = t) = defaultRender
            let value = Schema.get(form_data, schemaField)
            let onChange = (e) =>
                Schema.set(form_data, schemaField, e) |> onChange
            let rec loop = l => switch(l){
                | list{} => <DefaultComponent value onChange />
                | list{x, ...xs} => {
                let result = getRender(x)
                    switch(result){
                        |Some(module(Component)) => <Component onChange value/>
                        |_ => loop(xs)
                    }
                }
            }
            loop(renders)
        }   
        let handle_item = i => switch (i) {
            | Schema.Mk_field (Schema_string(s)) => {
                createSchemaField(
                    ~schemaField = s,
                    ~defaultRender = module(TextInputDefaultRender),
                    ~getRender = (MkRenderFieldByType(t, c)) => switch t {
                        | TextRender => Some(c)
                        | _ => None
                    }
                )
            }
            | Schema.Mk_field (Schema_number(n)) => {
                createSchemaField(
                    ~schemaField = n,
                    ~defaultRender = module(NumberInputDefaultRender),
                    ~getRender = (MkRenderFieldByType(t, c)) => switch t {
                        | NumberRender => Some(c)
                        | _ => None
                    }
                )
            }
            | Schema.Mk_field (Schema_boolean(b)) => {
                createSchemaField(
                    ~schemaField = b,
                    ~defaultRender = module(BoolInputDefaultRender),
                    ~getRender = (MkRenderFieldByType(t, c)) => switch t {
                        | BoolRender => Some(c)
                        | _ => None
                    }
                )
            }
            | Schema.Mk_field (Schema_object(o)) => 
                <div style=(ReactDOM.Style.make(~marginTop="20px", ~marginLeft="40px", ()))>
                    {handle_object_field(o)}
                </div>
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
let make = (~schema: module (Object with type t = 'a), ~form_data: 'a, ~onChange: ('a => ()), ~renders: renders) =>
    <div>
        { schema_render(form_data, schema, ~renders, ~onChange) }
    </div>