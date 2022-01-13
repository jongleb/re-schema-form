module TestForm = {
  // module ProofIncomeWidget = {
  //   type t = float

  //   @react.component
  //   let make = (~value: float, ~onChange: float => unit) => {
  //     let onChange = React.useCallback1(
  //       e => ReactEvent.Form.target(e)["valueAsNumber"] |> onChange,
  //       [onChange],
  //     )
  //     <input style={ReactDOM.Style.make(~color="#71bc78", ~fontSize="50px", ())} value=Belt_Float.toString(value) type_="number" onChange />
  //   }
  //   React.setDisplayName(make, "AgeWidget")
  // }

  // module UserTest = %schema(
  //   type sc_meta_data = Num(string) | Date(int)
  //   type oneMoreType = {
  //     someStrangeValue: float
  //   }
  //   type addInfo = {
  //     fullName: string,
  //     @sc_meta(Date(123))
  //     personBirthday: string,
  //     isPension: bool,
  //     maybeString: option<string>,
  //     arrayField: array<string>,
  //     arrayWithObj: array<oneMoreType>,
  //   }
  //   type income = {
  //     @sc_widget(module(ProofIncomeWidget: Widgets.Widget with type t = float))
  //     proofIncome: float
  //   }
  //   type formData = {
  //     addInfo,
  //     income,
  //   }
  // )

  // open UserTest

  // let firstOneMore = {someStrangeValue: 0.}
  // let addInfo = { personBirthday: "22.11.1995"
  //   , fullName: "Ivanov Ivan Ivanovich"
  //   , isPension: false
  //   , maybeString: None
  //   , arrayField: ["a", "b"]
  //   , arrayWithObj: [firstOneMore]
  // }
  // let income = {proofIncome: 100000.5}
  // let formData = { addInfo, income }

  module RegisterFormSchema = %schema(
    type formData = {
      phone: string,
      age: int,
      name: string,
      password: string,
      confirmPassword: string
    }
  )

  open RegisterFormSchema

  let formData = {
    phone: "",
    age: 0,
    name: "",
    password: "",
    confirmPassword: "",
  }

  module AllStringTypeWidget = {
    type t = string

    @react.component
    let make = (~value: t, ~onChange: t => unit) => {
      let onChange = React.useCallback1(
        e => ReactEvent.Form.target(e)["value"] |> onChange,
        [onChange],
      )
      <input type_="text" placeholder="Empty String Widget" value onChange />
    }
    React.setDisplayName(make, "AgeWidget")
  }

  let customPrimitives: PrimitiveWidget.customWidgets = {
    stringWidget: Some(module(AllStringTypeWidget)),
    intWidget: None,
    floatWidget: None,
    boolWidget: None,
  }

  @react.component
  let make = () => {
    let (state, setState) = React.useState(_ => formData)

    let onChange = v => {
      Js.Console.log(v)
      setState(_ => v)
    }
    <FormRender uiSchema formData=state schema onChange customPrimitives />
  }
}

ReactDOM.render(
  <React.StrictMode> <TestForm /> </React.StrictMode>,
  ReactDOM.querySelector("#root")->Belt.Option.getExn,
)
