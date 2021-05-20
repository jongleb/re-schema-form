open Schema.Schema_object


let rec schema_render: type a . ~onChange: ((a) => ()) => a => (module (Object with type t = a)) => React.element =
 (~onChange, form_data: a, (module(Schema)): (module(Object with type t = a))) => {
    let handle_object_field: type f . ((Schema.field<f>, (module (Object with type t = f)))) => React.element = (pair: (Schema.field<f>, (module (Object with type t = f)))) => {
      let (field, m) = pair
      let next_data = Schema.get(form_data, field)
      let next_on_change = upd => onChange(Schema.set(form_data, field, upd))
      schema_render(next_data, m, ~onChange=next_on_change)
    }
    let handle_item = i => switch (i) {
     | Schema.Mk_field (Schema_string(s)) => {
        let str = Schema.get(form_data, s)
        let onChange = (e) =>
            Schema.set(form_data, s, ReactEvent.Form.target(e)["value"]) |> onChange
        <input type_="text" value=str onChange />
     }
     | Schema.Mk_field (Schema_number(n)) => {
        let int = Schema.get(form_data, n)
        let onChange = (e) =>
            Schema.set(form_data, n, ReactEvent.Form.target(e)["value"]) |> onChange
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
let make = (~schema: module (Object with type t = 'a), ~form_data: 'a, ~onChange: ('a => ())) =>
    <div>
        { schema_render(form_data, schema, ~onChange) }
    </div>