open Schema

module TestForm = {
  type fullName = {
    name: string,
    surname: string,
    middleName: string,
  }
  type user = {
    age: int,
    fullName: fullName,
  }
  module AgeField = {
    type t = int
    type r = user
    type meta = int
    let get = user => user.age
    let set = (user, age) => {...user, age: age}
  }
  module FullNameField = {
    type t = fullName
    type r = user
    type meta = int
    let get = user => user.fullName
    let set = (user, fullName) => {...user, fullName: fullName}
  }
  module NameField = {
    type t = string
    type r = fullName
    type meta = int
    let get = fullName => fullName.name
    let set = (fullName, name) => {...fullName, name: name}
  }
  module SurNameField = {
    type t = string
    type r = fullName
    type meta = int
    let get = fullName => fullName.surname
    let set = (fullName, surname) => {...fullName, surname: surname}
  }
  module MiddleField = {
    type t = string
    type r = fullName
    type meta = int
    let get = fullName => fullName.middleName
    let set = (fullName, middleName) => {...fullName, middleName: middleName}
  }
  module UserField = {
    type t = user
    type r = user
    type meta = int
    let get = user => user
    let set = (_, user) => user
  }
  let schema: Schema.t<obj, user, user> = SObject([
    SchemaListItem(SchemaElement(Primitive(SInt), module(AgeField))),
    SchemaListItem(SchemaElement(SObject([
        SchemaListItem(SchemaElement(Primitive(SString), module(NameField))),
        SchemaListItem(SchemaElement(Primitive(SString), module(SurNameField))),
        SchemaListItem(SchemaElement(Primitive(SString), module(MiddleField))),
    ]), module(FullNameField))),
  ])

  let formData = {
      age: 34,
      fullName: {
          name: "Testovik",
          surname: "Testoviy",
          middleName: "Testovich"
      }
  }

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