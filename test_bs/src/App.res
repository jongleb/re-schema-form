open SchemaRender

module NameInputRender = {
  type t = string
  @react.component
  let make = (~value: t, ~onChange: t => ()) => {
    let style = ReactDOM.Style.make(~color="#71bc78", ~fontSize="28px", ())
    let onChange = e => ReactEvent.Form.target(e)["value"] |> onChange
    <input style type_="text" value onChange />
  }
} 

module AgeInputRender = {
  type t = int
  @react.component
  let make = (~value: t, ~onChange: t => ()) => {
    let style = ReactDOM.Style.make(~color="#007dff", ~fontSize="28px", ())
    let onChange = e => ReactEvent.Form.target(e)["valueAsNumber"] |> onChange
    <input style type_="number" value=Belt.Int.toString(value) onChange />
  }
}

module SomeNullableFieldInputRender = {
  type t = option<int>
  @react.component
  let make = (~value: t, ~onChange: t => ()) => {
    let style = ReactDOM.Style.make(~color="#007dff", ~fontSize="28px", ())
    let onChange = e => Some(ReactEvent.Form.target(e)["valueAsNumber"]) |> onChange
    let inputValue = switch value {
      | Some(v) => Belt.Int.toString(v)
      | _ => ""
    }
    <input style type_="number" value=inputValue onChange />
  }
}

module StateSchema = %schema(
 type schema_meta = {name: string}
 type passport = {
   address: string,
   is_male: bool,
 }
 type app = {
   passport,
   @schema.ui.render(module(NameInputRender))
   @schema.meta({name: "Name 2"})
   name2: string,
   @schema.ui.render(module(AgeInputRender))
   age: int,
   test_field: int,
   money: float,
   some_nullable_field: option<string>,
   @schema.ui.render(module(SomeNullableFieldInputRender))
   some_nullable_field_2: option<int>,
   some_array_field: array<int>,
   some_array_field_bool: array<bool>
 }
);

open StateSchema;

module FieldWrapRender = {
  type t = option<StateSchema.schema_meta>
  @react.component
  let make = (~meta: option<StateSchema.schema_meta>, ~children ) => {
    let { name } = {name: "No label"} |> Belt.Option.getWithDefault(meta)
    (
      <div>
        <span>{name |> React.string}</span>
        <div>{children}</div>
      </div>
    )
  }
}

let passport = {
  address: "Moscow",
  is_male: true,
}
let app = {
  name2: "Name!",
  age: 666,
  test_field: 900,
  money: 34.6,
  passport,
  some_nullable_field: None,
  some_nullable_field_2: None,
  some_array_field: [1,2,3,4],
  some_array_field_bool: [true, true, true, false]
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
  MkRenderFieldByType(NumberRender(NumberIntRender), module(NumberInputRender))
])

@react.component
let make = () => {
  let (state, setState) = React.useState(_ => app);

  let onChange = v => {
      Js.Console.log(v);
      setState(_ => v);
  };

  <SchemaRender field_wrappers=[(FieldWrap, module(FieldWrapRender))] renders schema=(module(App_schema_config)) form_data=state onChange /> 
};