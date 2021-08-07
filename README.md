# Re-schema-form
## Rescript form render
Re-schema-form is a meta based render.  This can be especially useful for generating large forms with predefined templates. That is, we want to generate a form based on some kind of scheme. But at the same time, we do not want to describe the circuit separately and separately have the type. **ppx** is in my opinion the best solution for this

### Features
 
 First of all!  This idea is not new. https://github.com/rjsf-team/react-jsonschema-form
 But the main difference is that in rjsf we must define the FormData type and also describe the schema itself. **BUT** in react-schema-form we should define only our type (form data type)
 
```rescript
module StateSchema = %schema(
  type schema_meta = {name: string}
  type app = {
    first_field: string,
    second_field: int
  }
);
``` 

Also take a look at this https://github.com/Astrocoders/lenses-ppx project for a better understanding of how ppx works. In addition, the generation of lenses is borrowed from there
**Thank!** 🙏

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

#### Simple example
[Demo](https://re-schema-form-gw2zquki4-jongleb.vercel.app/#1)
[Source](https://github.com/jongleb/re-schema-form/blob/master/examples/src/App.res)

#### Custom render
[Demo](https://re-schema-form-gw2zquki4-jongleb.vercel.app/#2)
[Source](https://github.com/jongleb/re-schema-form/blob/master/examples/src/CustomRenderByType.res)

#### Custom render concrete field
[Demo](https://re-schema-form-gw2zquki4-jongleb.vercel.app/#3)
[Source](https://github.com/jongleb/re-schema-form/blob/master/examples/src/ConcreteFieldRender.res)

#### Field wrapper
[Demo](https://re-schema-form-gw2zquki4-jongleb.vercel.app/#4)
[Source](https://github.com/jongleb/re-schema-form/blob/master/examples/src/FieldWrapperExample.res)

#### Option (Nullable field) and render (for exmaple)
[Demo](https://re-schema-form-gw2zquki4-jongleb.vercel.app/#5)
[Source](https://github.com/jongleb/re-schema-form/blob/master/examples/src/NullableField.res)