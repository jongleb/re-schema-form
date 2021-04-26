open Schema

module StateSchema = %schema(
 type passport = {
   address: string,
   is_some: bool,
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
  is_some: false,
}
let app = {
  name: "Name",
  age: 666,
  passport
}

ReactDOM.render(
  <React.StrictMode> 
    <SchemaRender schema=(module(App)) form_data=app /> 
  </React.StrictMode>,
  ReactDOM.querySelector("#root")->Belt.Option.getExn,
)