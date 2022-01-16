---
sidebar_position: 3
---

# Custom FieldTemplate

We already know how to define custom widgets
But what about **the label** and the **place for the error output**? How is our **field**?

Yes it's time to **FieldTemplate**

We need to implement this module type

```reason
module type FieldTemplate = {
  @react.component
  let make: (~value: 't, ~onChange: 't => unit, ~children: React.element, ~meta: 'm) => React.element
}
```

where 

```reason
 ~children: React.element
```

it's our **Widget**

Let's add labels to our fields. To do this, you need to create your own **custom type**.

Let's declare it **above all** the code

```reason
type meta = {title: string}
```

Now let's implement **FieldTemplate** component

```reason
module CustomFieldTemplate = {
  type m = meta

  @react.component
  let make = (~value as _, ~onChange as _, ~children: React.element, ~meta) =>
    <div>
      <label> {Belt_Option.getWithDefault(meta, {title: ""}).title |> React.string} </label>
      {children}
    </div>
}
```

where ~meta it's our ```{title: string}```

Now we need to pass the **schema type** and add a title to **our fields**

```reason
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
```

**sc_meta_data** - here you need to pass the type of the meta

**@sc_meta(..)** - pass here value of meta type

And finally pass our **CustomFieldTemplate** to **props**

```reason
 <FormRender
    fieldTemplate=module(CustomFieldTemplate)
    uiSchema
    formData=state
    schema
    onChange
    customPrimitives
  />
```