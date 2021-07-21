# Re-schema-form
## Rescript form render
Re-schema-form is a meta based render.  This can be especially useful for generating large forms with predefined templates. That is, we want to generate a form based on some kind of scheme. But at the same time, we do not want to describe the circuit separately and separately have the type. **ppx** is in my opinion the best solution for this

### Features
 
 First of all!  This idea is not new. https://github.com/rjsf-team/react-jsonschema-form
 But the main difference is that in rjsf we must define the FormData type and also describe the schema itself. **BUT** in react-schema-form we should define only our type (form data type)
 
```rescript
module StateSchema = %schema(
  type schema_meta = {name: string}
  type app = {
    first_field: string,
    second_field: int
  }
);
``` 

Also take a look at this https://github.com/Astrocoders/lenses-ppx project for a better understanding of how ppx works. In addition, the generation of lenses is borrowed from there


### Installation

```sh
npm i re-schema-form
```
Add to you bsconfig

```json
{
    "bs-dependencies": ["re-schema-form"],
    "ppx-flags": ["re-schema-form/ppx"],
}
```

Okay, start

```rescript
open SchemaRender


module StateSchema = %schema(
 type schema_meta = {name: string}
 type app = {
   first_field: string,
   second_field: int
 }
);

open StateSchema

let form_data = {
 first_field: "Abcd",
 second_field: 123,
}

module App = {
  @react.component
  let make = () => {
    let (state, setState) = React.useState(_ => form_data);

     let onChange = v => {
        Js.Console.log(v);
        setState(_ => v);
     };

    <SchemaRender
      field_wrappers=[]
      renders=list{}
      schema=(module(App_schema_config))
      form_data=state onChange
    />
  }
}
```
![image](https://i.ibb.co/nf7by36/2021-07-21-09-52-58.png)

Then, of course, we want to dress up our field.
We can do this by type
```rescript
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
```

And update

```rescript
<SchemaRender
      field_wrappers=[]
      renders
      schema=(module(App_schema_config))
      form_data=state onChange
    />
```

![image](https://i.ibb.co/ZJcdWn0/2021-07-21-09-58-51.png)

We have renders for all occasions

```rescript
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
```  

And next we want to dress up concrete field

```rescript
module FirstFieldInputRender = {
  type t = string
  @react.component
  let make = (~value: t, ~onChange: t => ()) => {
    let style = ReactDOM.Style.make(~color="#71bc78", ~fontSize="28px", ())
    let onChange = e => ReactEvent.Form.target(e)["value"] |> onChange
    <input style type_="text" value onChange />
  }
}

module StateSchema = %schema(
 type schema_meta = {name: string}
 type app = {
   @schema.ui.render(module(FirstFieldInputRender))
   first_field: string,
   second_field: int
 }
);
```

![image](https://i.ibb.co/J3vcPJm/2021-07-21-10-03-34.png)

And usually in forms we want to always have a wrapper over the field

Chose you field type

```rescript
type common_field_wrap =
  | FieldWrap
  | NullableFieldWrap
  | ArrayFieldWrap
  | ObjectFieldWrap
```

And we also need to produce meta data, like name , label, etc

```rescript
module FieldWrapRender = {
  type t = option<StateSchema.schema_meta>
  @react.component
  let make = (
    ~meta: option<StateSchema.schema_meta>,
    ~children: React.element,
  ) => {
    let {name} = {name: "No label"} |> Belt.Option.getWithDefault(meta)

    <div> <span> {name |> React.string} </span> <div> {children} </div> </div>
  }
}
```

And
```rescript
<SchemaRender
      field_wrappers=[(FieldWrap, module(FieldWrapRender))]
      renders
      schema=(module(App_schema_config))
      form_data=state
      onChange
    />
```

![image](https://i.ibb.co/M8MVfyJ/2021-07-21-10-30-19.png)

Ooo, we forgot to update something

```rescript
module StateSchema = %schema(
 type schema_meta = {name: string}
 type app = {
   @schema.ui.render(module(FirstFieldInputRender))
   @schema.meta({ name: "THE FIRST THE FIELD" })
   first_field: string,
   @schema.meta({ name: "THE SECOND THE FIELD" })
   second_field: int
 }
);
```
Yeeep
![image](https://i.ibb.co/9tVQ2zF/2021-07-21-10-32-52.png)

Now we want to add for example nullable field

```rescript
module StateSchema = %schema(
 type schema_meta = {name: string}
 type app = {
   @schema.ui.render(module(FirstFieldInputRender))
   @schema.meta({ name: "THE FIRST THE FIELD" })
   first_field: string,
   @schema.meta({ name: "THE SECOND THE FIELD" })
   second_field: int,
   nullable_test_field: option<int>
 }
);

let form_data = {
 first_field: "Abcd",
 second_field: 123,
 nullable_test_field: None
}
```

![image](https://i.ibb.co/D9wXhhW/2021-07-21-10-35-35.png)

Hmm, it looks very boring, let's define a field wrapper for ALL nullable

```rescript
<SchemaRender
      field_wrappers=[
        (FieldWrap, module(FieldWrapRender)),
        (NullableFieldWrap, module(NullableFieldWrapRender))
      ]
```
![image](https://i.ibb.co/nmH1hW1/2021-07-21-10-38-17.png)
    


    
