open Schema
open Widgets

type props<'t, 'r> = {
    obj: 'r,
    field: Schema.t<primitive<'t>, 'r, 't>,
    onChange: 'r => ()
};

@obj external makeProps:(
    ~obj: 'r, 
    ~field: Schema.t<<primitive<'t>, 'r, 't>, 
    ~onChange: 'r => ()
) => props<'t, 'r> = ""

let make = (type t, type r, props: props<t, r>) => {
   let Primitive(p, module(Field): module(Field with type t = t and type r = r)) = props.field
   let onChange = React.useCallback0((val: t) => {
    val |> Field.set(props.obj) |> props.onChange
   })
   switch p {
   | SString => <StringWidget onChange value=Field.get(props.obj) />
   | _ => React.string("Not implemented")
   }
}