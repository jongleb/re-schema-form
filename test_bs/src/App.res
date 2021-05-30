open Schema
open SchemaRender

module StateSchema = %schema(
 type passport = {
   address: string,
   is_male: bool,
 } 
 type app = {
   passport,
   name: string,
   age: int,
   test_field: int,
 }
);

open StateSchema;

let passport = {
  address: "Moscow",
  is_male: false,
}
let app = {
  name: "Name",
  age: 666,
  test_field: 900,
  passport
}

module TextInputRender = {
  type t = string
  @react.component
  let make = (~value: t, ~onChange: t => ()) => {
    let style = ReactDOM.Style.make(~color="#444444", ~fontSize="28px", ())
    let onChange = e => ReactEvent.Form.target(e)["value"] |> onChange
    <input style type_="text" value onChange />
  }
}

module NumberInputRender = {
  type t = int
  @react.component
  let make = (~value: t, ~onChange: t => ()) => {
    let onChange = e => ReactEvent.Form.target(e)["valueAsNumber"] |> onChange
    let style = ReactDOM.Style.make(~color="red", ~fontSize="28px", ())
    <input style type_="number" value=Belt.Int.toString(value) onChange />
  }
}

let renders = Belt_List.fromArray([
  MkRenderFieldByType(TextRender, module(TextInputRender)),
  MkRenderFieldByType(NumberRender, module(NumberInputRender))
])

@react.component
let make = () => {
  let (state, setState) = React.useState(_ => app);

  let onChange = v => {
      Js.Console.log(v);
      setState(_ => v);
  };

  <SchemaRender renders schema=(module(App)) form_data=state onChange /> 
};