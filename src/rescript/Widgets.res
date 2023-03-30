module type Widget = {
  type t
  @react.component
  let make: (~value: t, ~onChange: t => unit) => React.element
}

module TextUnhadledEventWidget = {
  @react.component
  let make = (~value: string, ~onChange: 'a => unit, @as("type") ~type_: string) => {
    let onChange = React.useCallback1(e => ReactEvent.Form.target(e) |> onChange, [onChange])
    <input value={value} type_ onChange />
  }
  let () = React.setDisplayName(make, "TextWidget")
}

module StringWidget = {
  type t = string
  @react.component
  let make = (~value: string, ~onChange: string => unit) => {
    <TextUnhadledEventWidget type_="text" value onChange={e => onChange(e["value"])} />
  }
  let () = React.setDisplayName(make, "StringWidget")
}

module NumberWidget = {
  @react.component
  let make = (~value: string, ~onChange: 'a => unit) => {
    <TextUnhadledEventWidget type_="number" value onChange={e => onChange(e["valueAsNumber"])} />
  }
  let () = React.setDisplayName(make, "NumberWidget")
}

module IntWidget = {
  type t = int
  @react.component
  let make = (~value: int, ~onChange: int => unit) => {
    <NumberWidget value={Belt_Int.toString(value)} onChange />
  }
  let () = React.setDisplayName(make, "IntWidget")
}

module FloatWidget = {
  type t = float
  @react.component
  let make = (~value: float, ~onChange: float => unit) => {
    <NumberWidget value={Belt_Float.toString(value)} onChange />
  }
  let () = React.setDisplayName(make, "IntWidget")
}

module BoolWidget = {
  type t = bool
  @react.component
  let make = (~value: bool, ~onChange: bool => unit) => {
    let onChange = React.useCallback1(
      e => ReactEvent.Form.target(e)["checked"] |> onChange,
      [onChange],
    )
    <input type_="checkbox" onChange checked=value />
  }
  let () = React.setDisplayName(make, "BoolWidget")
}