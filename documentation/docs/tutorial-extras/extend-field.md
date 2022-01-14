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
  let make: (~value: 't, ~onChange: 't => unit, ~children: React.element) => React.element
}
```

where 

```reason
 ~children: React.element
```

it's our **Widget**

