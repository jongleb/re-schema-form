module TestForm = {

  module UserTest = %schema(
    type sc_meta_data = { r: int }
    type fullName = {
      name: string,
    }
    type user = {
      fullName,
      age: int,
      height: float,
      isTest: bool,
      test2: array<int>
    }
  )

  open UserTest

  let fullName = {name: ""}
  let formData = { fullName, age: 23, height: 185.5, isTest: false, test2: [1,2,3] }

  @react.component
  let make = () => {
    
    let (state, setState) = React.useState(_ => formData);

     let onChange = v => {
        Js.Console.log(v);
        setState(_ => v);
     };
    <FormRender formData=state field=schema onChange />
  }
}


ReactDOM.render(
  <React.StrictMode> <TestForm /> </React.StrictMode>,
  ReactDOM.querySelector("#root")->Belt.Option.getExn,
)