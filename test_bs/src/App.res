open Schema

module StateSchema = %schema(
 type passport = {
   address: string,
   is_male: bool,
 } 
 type app = {
   passport,
   name: string,
   age: int,
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
  passport
}

@react.component
let make = () => {
  let (state, setState) = React.useState(_ => app);

  let onChange = v => setState(_ => v);

  <SchemaRender schema=(module(App)) form_data=state onChange /> 
};