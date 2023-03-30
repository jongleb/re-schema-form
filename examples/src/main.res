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

  module PasswordWidget = {
    type t = string

    @react.component
    let make = (~value: t, ~onChange: t => unit) => {
      let onChange = React.useCallback1(
        e => ReactEvent.Form.target(e)["value"] |> onChange,
        [onChange],
      )
      <input type_="password" placeholder="Empty password" value onChange />
    }
    React.setDisplayName(make, "Passwordidget")
  }

  type meta = {title: string}

  module CustomFieldTemplate: UiFields.FieldTemplate with type m = meta = {
    type m = meta
    @react.component
    let make = (~value as _, ~onChange as _, ~children: React.element, ~meta) =>
      <div>
        <label> {Belt_Option.getWithDefault(meta, {title: ""}).title |> React.string} </label>
        {children}
      </div>
  }

  module RegisterFormSchema = %schema(
    type sc_meta_data = meta
    type formData = {
      @sc_meta({title: "Phone"})
      phone: string,
      @sc_meta({title: "Age"})
      age: int,
      @sc_meta({title: "Name"})
      name: string,
      @sc_meta({title: "Password"})
      @sc_widget(module(PasswordWidget: Widgets.Widget with type t = string))
      password: string,
      @sc_meta({title: "Confrim password"})
      @sc_widget(module(PasswordWidget: Widgets.Widget with type t = string))
      confirmPassword: string,
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
    <FormRender
      fieldTemplate=module(CustomFieldTemplate)
      uiSchema
      formData=state
      schema
      onChange
      customPrimitives
    />
  }
}

switch ReactDOM.querySelector("#root") {
| Some(rootElement) => {
    let root = ReactDOM.Client.createRoot(rootElement)
    ReactDOM.Client.Root.render(root, <React.StrictMode> <TestForm /> </React.StrictMode>)
  }
| None => ()
}
