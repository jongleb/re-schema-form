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

  module SimpleFormSchema = %schema(
    type names = {
      middleName: string,
      name: string,
    }
    type flags = {isLoveCats: bool}
    type contact = {
      names: names,
      phone: string,
    }
    type greenCard = {
      names: names,
      id: int,
      photoLink: string,
    }
    type user = {
      names: names,
      age: int,
      flags: flags,
      phoneContacts: array<contact>,
      greenCard: option<greenCard>,
    }
  )

  open SimpleFormSchema

  let names = {middleName: "Some", name: "User"}
  let greenCard = {
    names: names,
    id: 1234567,
    photoLink: "https://play-lh.googleusercontent.com/6UgEjh8Xuts4nwdWzTnWH8QtLuHqRMUB7dp24JYVE2xcYzq4HA8hFfcAbU-R-PC_9uA1",
  }
  let phoneContactName = {middleName: "Best", name: "Friend"} // Well, how can it be without him?
  let firstPhoneContact = {names: phoneContactName, phone: "123456789"}
  let phoneContacts = [firstPhoneContact]
  let flags = {isLoveCats: true} // of course! who doesn't love them
  let formData = {
    names: names,
    age: 41,
    flags: flags,
    phoneContacts: phoneContacts,
    greenCard: Some(greenCard),
  }

  @react.component
  let make = () => {
    let (state, setState) = React.useState(_ => formData)

    let onChange = v => {
      Js.Console.log(v)
      setState(_ => v)
    }
    <FormRender uiSchema formData=state schema onChange />
  }
}

ReactDOM.render(
  <React.StrictMode> <TestForm /> </React.StrictMode>,
  ReactDOM.querySelector("#root")->Belt.Option.getExn,
)
