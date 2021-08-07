module StateSchema = %schema(
 type schema_meta = {name: string}
 type app = {
   @schema.meta({ name: "First field" })  
   first_field: string,
   second_field: int,
   and_some_boolean: bool,
   nullable_test_field: option<int>
 }
);

open StateSchema
open SchemaRender

let form_data = {
 first_field: "Custom render by type",
 second_field: 5678,
 and_some_boolean: true,
 nullable_test_field: None
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

module FieldWrapRender = {
  type t = option<schema_meta>
  @react.component
  let make = (
    ~meta: option<schema_meta>,
    ~children: React.element,
  ) => {
    let {name} = {name: "No label"} |> Belt.Option.getWithDefault(meta)

    <div>
        <label>{name |> React.string}</label>
        {children}
    </div>
  }
}

module NullableFieldWrapRender = {
  type t = option<schema_meta>
  @react.component
  let make = (
    ~meta: option<schema_meta>,
    ~children: React.element,
  ) => {
    let {name} = {name: "Wrapper for nullable field"} |> Belt.Option.getWithDefault(meta)

    <div>
        <label>{name |> React.string}</label>
        {children}
    </div>
  }
}

@react.component
  let make = () => {
    let (state, setState) = React.useState(_ => form_data);

     let onChange = v => {
        Js.Console.log(v);
        setState(_ => v);
     };

    <SchemaRender
      field_wrappers=[
        (FieldWrap, module(FieldWrapRender)),
        (NullableFieldWrap, module(NullableFieldWrapRender))
      ]
      renders
      schema=(module(App_schema_config))
      form_data=state onChange
    />
} 