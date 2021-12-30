---
sidebar_position: 3
---

# Add array field

And so, we know how to work with **primitives**, we know how with **nested fields**, but now it's time **for lists**. In this case, this is **an array**, (lists coming soon)

Let's pretend we have a notebook

```reason
type contact = {
  names: names,
  phone: string,
}
```

Simplify to number and name

And **update** our form data

```reason
type user = {
  names: names,
  age: int,
  flags: flags,
  phoneContacts: array<contact>,
}
```

update data


```reason
let phoneContactName = {middleName: "Best", name: "Friend"} // Well, how can it be without him?
let firstPhoneContact = {names: phoneContactName, phone: "123456789"}
let phoneContacts = [firstPhoneContact]
let names = {middleName: "Some", name: "User"}
let flags = {isLoveCats: true} // of course! who doesn't love them
let formData = {names: names, age: 41, flags: flags, phoneContacts: phoneContacts}
```


Here is the **final** listing of the program, it's time to **open the browser**

```reason
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
    type user = {
      names: names,
      age: int,
      flags: flags,
      phoneContacts: array<contact>,
    }
  )

  open SimpleFormSchema

  let phoneContactName = {middleName: "Best", name: "Friend"} // Well, how can it be without him?
  let firstPhoneContact = {names: phoneContactName, phone: "123456789"}
  let phoneContacts = [firstPhoneContact]
  let names = {middleName: "Some", name: "User"}
  let flags = {isLoveCats: true} // of course! who doesn't love them
  let formData = {names: names, age: 41, flags: flags, phoneContacts: phoneContacts}

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
```