open Schema

@react.component
let make = (~obj: 'r, ~schemaObject: Schema.t<obj, 'r, 't>, ~onChange: ('t) => unit) => {
   let SObject(arr, b) = schemaObject
   
   // Array.map()
}