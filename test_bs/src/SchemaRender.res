open Schema.Schema_object

module type FieldRender = {
  type t
  @react.component
  let make: (~value: t, ~onChange: ReactEvent.Form.t => ()) => React.element
}

type rec render_field<_> =
    | NumberRender: render_field<int>
    | TextRender: render_field<string>
    | BoolRender: render_field<bool>

@unboxed
type rec render_wrap = 
    MkRender((render_field<'a>, (module(FieldRender with type t = 'a)))) : render_wrap;

type renders = array<render_wrap>

let rec schema_render: type a . (~renders: renders, ~onChange: ((a) => ())) => a => (module (Object with type t = a)) => React.element =
 (~renders, ~onChange, form_data: a, (module(Schema)): (module(Object with type t = a))) => {
    let handle_object_field: type f . ((Schema.field<f>, (module (Object with type t = f)))) => React.element = (pair: (Schema.field<f>, (module (Object with type t = f)))) => {
      let (field, m) = pair
      let next_data = Schema.get(form_data, field)
      let next_on_change = upd => onChange(Schema.set(form_data, field, upd))
      schema_render(next_data, m, ~onChange=next_on_change, ~renders=renders)
    }
    let handle_item = i => switch (i) {
     | Schema.Mk_field (Schema_string(s)) => {
        let value = Schema.get(form_data, s)
        let onChange = (e: ReactEvent.Form.t) =>
            Schema.set(form_data, s, ReactEvent.Form.target(e)["value"]) |> onChange
        let render = Belt_Array.getBy(renders, (MkRender(t, _)) => switch t {
            | TextRender => true
            | _ => false
        })
        switch(render){
            | Some(MkRender(t, module(Component))) => switch t {
                | TextRender => <Component value onChange />
                | _ => <input type_="text" value onChange />
            }
            | None => <input type_="text" value onChange />
        }
     }
     | Schema.Mk_field (Schema_number(n)) => {
        let int = Schema.get(form_data, n)
        let onChange = (e) =>
            Schema.set(form_data, n, ReactEvent.Form.target(e)["valueAsNumber"]) |> onChange
        <input type_="number" value=Belt.Int.toString(int) onChange />
     }
     | Schema.Mk_field (Schema_boolean(b)) => {
        let bool = Schema.get(form_data, b)
        let onChange = (e) =>
            Schema.set(form_data, b, ReactEvent.Form.target(e)["checked"]) |> onChange
        <input type_="checkbox" checked=bool onChange />
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

@react.component
let make = (~schema: module (Object with type t = 'a), ~form_data: 'a, ~onChange: ('a => ()), ~renders) =>
    <div>
        { schema_render(form_data, schema, ~renders, ~onChange) }
    </div>