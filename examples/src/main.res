module TestForm = {

  module AgeWidget = {
    type t = int
    
    @react.component
    let make = (~value: int, ~onChange: int => unit) => {
      let onChange = React.useCallback1(
        e => ReactEvent.Form.target(e)["valueAsNumber"] |> onChange,
        [onChange],
      )
      <input style={ReactDOM.Style.make(~color="#71bc78", ~fontSize="28px", ())} value=Belt_Int.toString(value) type_="number" onChange />
    }
    React.setDisplayName(make, "AgeWidget")
  }

  module UserTest = %schema(
    type sc_meta_data = { r: int }
    type fullName = {
      name: string,
    }
    type user = {
      fullName,
      @sc_widget(module(AgeWidget: Widgets.Widget with type t = int))
      @sc_meta({r: 2})
      age: int,
      height: float,
      isTest: bool,
      test2: array<int>
    }
  )

  open UserTest

  let fullName = {name: ""}
  let formData = { fullName, age: 23, height: 185.5, isTest: false, test2: [2,34] }

  @react.component
  let make = () => {
    
    let (state, setState) = React.useState(_ => formData);

     let onChange = v => {
        Js.Console.log(v);
        setState(_ => v);
     };
    <FormRender uiSchema formData=state schema onChange />
  }
}


ReactDOM.render(
  <React.StrictMode> <TestForm /> </React.StrictMode>,
  ReactDOM.querySelector("#root")->Belt.Option.getExn,
)