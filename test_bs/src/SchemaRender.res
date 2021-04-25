open Schema.Schema_object

let rec schema_render: type a . a => (module (Object with type t = a)) => React.element =
 (form_data: a, (module(Schema)): (module(Object with type t = a))) => {
    let handle_object_field: type f . ((Schema.field<f>, (module (Object with type t = f)))) => React.element = (pair: (Schema.field<f>, (module (Object with type t = f)))) => {
      let (field, m) = pair
      let next_data = Schema.get(form_data, field)
      schema_render(next_data, m)
    }
    let handle_item = i => switch (i) {
     | Schema.Mk_field (Schema_string(s)) => {
        let str = Schema.get(form_data, s)
        <input type_="text" value=str />
     }
     | Schema.Mk_field (Schema_number(n)) => {
        let int = Schema.get(form_data, n)
        <input type_="number" value=Belt.Int.toString(int) />
     }
     | Schema.Mk_field (Schema_boolean(b)) => {
        let bool = Schema.get(form_data, b)
        <input type_="checkbox" checked=bool />
     }
     | Schema.Mk_field (Schema_object(o)) => <div>{handle_object_field(o)}</div>
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
let make = (~schema: module (Object with type t = 'a), ~form_data: 'a) =>
    <div>
        { schema_render(form_data, schema) }
    </div>