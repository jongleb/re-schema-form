---
sidebar_position: 1
---

# Generate simple form

Create empty module with extension ```%schema(..)```

```reason
module SimpleFormSchema = %schema(
    
)
```

And for example we will use **user** type, and we will add fields step by step.

```reason
module SimpleFormSchema = %schema(
    type user = {
        age: int
    }
)
```

Now we can **define** our form data

```reason
open SimpleFormSchema

let formData = { age: 21 }
```

In fact, everything **is already ready** and we can call react component ***FormRender*** and  to check our result in your browser.

Do not worry about other props, we will talk about them later, just copy this call to your code

```jsx
<FormRender uiSchema formData schema onChange />
```

```reason
module SimpleFormSchema = %schema(
      type user = {
          age: int
      }
  )

open SimpleFormSchema

let formData = { age: 21 }

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