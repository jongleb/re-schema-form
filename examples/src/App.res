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