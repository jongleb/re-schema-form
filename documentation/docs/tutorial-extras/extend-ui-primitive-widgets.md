---
sidebar_position: 1
---

# Custom primitive widgets

Let's define custom primitive widgets. 

## Possible widgets
(see [PrimitiveWidgets](https://github.com/jongleb/re-schema-form/blob/master/src/rescript/PrimitiveWidget.res))
```reason
type customWidgets = {
  boolWidget: option<module(Widget with type t = bool)>,
  floatWidget: option<module(Widget with type t = float)>,
  intWidget: option<module(Widget with type t = int)>,
  stringWidget: option<module(Widget with type t = string)>,
}
```

And [Widget](https://github.com/jongleb/re-schema-form/blob/master/src/rescript/Widgets.res#L1)

## Create a register form

Let's create a new shape. Registration form

```reason
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

  @react.component
  let make = () => {
    let (state, setState) = React.useState(_ => formData)

    let onChange = v => {
      Js.Console.log(v)
      setState(_ => v)
    }
    <FormRender uiSchema formData=state schema onChange />
  }
```

### Create String widget

Now we want to define a widget for all fields with type **String**

```reason
module AllStringTypeWidget = {
    type t = string

    @react.component
    let make = (~value: t, ~onChange: t => unit) => {
      let onChange = React.useCallback1(
        e => ReactEvent.Form.target(e)["value"] |> onChange,
        [onChange],
      ) 
      //You can implement what you want
      <input type_="text" placeholder="Empty String Widget" value onChange />
    }
    let () = React.setDisplayName(make, "AllStringTypeWidget")
  }
```

(see [PrimitiveWidgets](https://github.com/jongleb/re-schema-form/blob/master/src/rescript/PrimitiveWidget.res))

And create preset

```reason
let customPrimitives: PrimitiveWidget.customWidgets = { // or open PrimitiveWidget
  stringWidget: Some(module(AllStringTypeWidget)), // < ----- Our widget
  intWidget: None, // < ----- Implement if you need
  floatWidget: None,  // < ----- Implement if you need
  boolWidget: None,  // < ----- Implement if you need
}
``` 

And pass it into props 

```reason
<FormRender uiSchema formData=state schema onChange customPrimitives />
```

Open your browser and enjoy the special placeholder for text fields