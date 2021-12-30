---
sidebar_position: 4
---

# Add optional (nullable)

I have a bad imagination, I don't know if it's appropriate, but let's imagine the presence or absence of data **on some document**, for example, on a green card

```reason
type greenCard = {
  names: names,
  id: int,
  photoLink: string,
}
```

Even so, I don’t know, I didn’t win it

And **update** our form data again

```reason
type user = {
  names: names,
  age: int,
  flags: flags,
  phoneContacts: array<contact>,
  greenCard: option<greenCard>
}
```

update data

```reason
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
```

Yes, yes, yes, put it all together, and open browser

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
```