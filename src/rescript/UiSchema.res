open Schema

module FieldCmp = Belt.Id.MakeComparable({
  type t = module(Field)
  let cmp = Pervasives.compare
})

type objectFieldTemplateProperty = {
    content: React.element
}

module type ObjectFieldTemplate = {
  @react.component
  let make: (~properties: array<objectFieldTemplateProperty>) => React.element
}
