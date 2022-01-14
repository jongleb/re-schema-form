---
sidebar_position: 2
---

# Custom widget for field

Continuing to fiddle with our **registration form**. We want to **mask** the **password** field.
We have **two options**, either **parametrize** the string widget or **define another widget** for the password

We will learn how to parameterize in the **meta chapter**, now let's define a **special widget** for passwords

Create **before all** declarations (and type) our **Widget**

```reason
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
    React.setDisplayName(make, "PasswordWidget")
  }
```

And then attach it to our password fields

```reason
  module RegisterFormSchema = %schema(
    type formData = {
      phone: string,
      age: int,
      name: string,
      @sc_widget(module(PasswordWidget: Widgets.Widget with type t = string))
      password: string,
      @sc_widget(module(PasswordWidget: Widgets.Widget with type t = string))
      confirmPassword: string
    }
  )
```

That's all

You can run to open a browser and check the results.

### Full listing

```reason
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

  module RegisterFormSchema = %schema(
    type formData = {
      phone: string,
      age: int,
      name: string,
      @sc_widget(module(PasswordWidget: Widgets.Widget with type t = string))
      password: string,
      @sc_widget(module(PasswordWidget: Widgets.Widget with type t = string))
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
```