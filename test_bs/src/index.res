open Schema

module StateSchema = %schema(
 type another_one = {
   abcd: string,
 }
 type state = {
   email: string,
   age: int,
   test2: string,
   test3: another_one,
 };
);

open StateSchema;

let ano = { abcd: "HELLO MAOTHER FOCUKER" }
let form_data = { email: "abcd@mail.ry", age: 11, test2: "fdsdf", test3: ano }

ReactDOM.render(
  <React.StrictMode> 
    <SchemaRender schema=(module(State)) form_data /> 
  </React.StrictMode>,
  ReactDOM.querySelector("#root")->Belt.Option.getExn,
)