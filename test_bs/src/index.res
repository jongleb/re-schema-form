module StateSchema = %schema(
 type subsub = {
   tests: bool,
 };
 type substate = {
   test: string,
   subsub,
 }; 
 type state = {
   email: string,
   age: int,
   test2: string,
   substate,
   tost: List.t<substate>,
 };
);
Js.Console.log(StateSchema.schema);

ReactDOM.render(
  <App schema={StateSchema.schema} />,
  ReactDOM.querySelector("#root")->Belt.Option.getExn,
)