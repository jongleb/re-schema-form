# Re-schema-form
## Rescript form render
Re-schema-form is a meta based render.  This can be especially useful for generating large forms with predefined templates. That is, we want to generate a form based on some kind of scheme. But at the same time, we do not want to describe the circuit separately and separately have the type. **ppx** is in my opinion the best solution for this

### Documentation
[Open documentation](https://re-schema-form-documentation.vercel.app/)

### Features
You should only focus on the **data type** and on **templates** and **styles**.
Rescript form render will take care of the rest
 
```rescript
module StateSchema = %schema(
    type subType = {flag: bool}
    type app = {
      firstField: string,
      secondField: int,
      subType: subType,
    }
  )

  // Yes it's all, schema already generated
  // We need only render Component

  let subType: StateSchema.subType = {flag: false}
  let formData: StateSchema.app = {
    firstField: "Initial",
    secondField: 1,
    subType: subType,
  }

  @react.component
  let make = () => {
    let (_, setState) = React.useState(_ => formData)

    let onChange = v => {
      Js.Console.log(v)
      setState(_ => v)
    }
    <FormRender uiSchema=StateSchema.uiSchema schema=StateSchema.schema onChange formData />
  }
``` 

### Installation

```sh
npm i re-schema-form
```
Add to you bsconfig

```json
{
    "bs-dependencies": ["re-schema-form"],
    "ppx-flags": ["re-schema-form/ppx"],
}
```

Okay, start

## Examples and sources

I' am working on it
