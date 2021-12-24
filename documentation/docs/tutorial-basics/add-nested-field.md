---
sidebar_position: 2
---

# Add nested field

Let's go back to our user. Let's **add a first and last name** field to it:

```reason
type names = {
  middleName: string,
  name: string,
}
type user = {
  names,
  age: int
}
```
***Don't forget*** to update our formData.

Open browser tab, check.. And yes, **it works**

And just to spice things up, let's add a checkbox.

```reason
 module SimpleFormSchema = %schema(
    type names = {
      middleName: string,
      name: string,
    }
    type flags = {
      isLoveCats: bool
    }
    type user = {
      names,
      age: int,
      flags
    }
  )

  open SimpleFormSchema

  let names = { middleName: "Some", name: "User" }
  let flags = { isLoveCats: true } // of course! who doesn't love them
  let formData = { names, age: 41, flags }

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
```