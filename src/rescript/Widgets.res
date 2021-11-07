module type Widget = {
  type t

  @react.component
  let make: (~value: t, ~onChange: t => unit) => React.element
}

module StringWidget = {
  @react.component
  let make = (~value: string, ~onChange: string => unit) => {
    let onChange = React.useCallback1(
      e => ReactEvent.Form.target(e)["value"] |> onChange,
      [onChange],
    )
    <input value type_="text" onChange />
  }
  React.setDisplayName(make, "StringWidget")
}

module IntWidget = {
  @react.component
  let make = (~value: int, ~onChange: int => unit) => {
    let onChange = React.useCallback1(
      e => ReactEvent.Form.target(e)["valueAsNumber"] |> onChange,
      [onChange],
    )
    <input value=Belt_Int.toString(value) type_="number" onChange />
  }
  React.setDisplayName(make, "IntWidget")
}

module FloatWidget = {
  @react.component
  let make = (~value: float, ~onChange: float => unit) => {
    let onChange = React.useCallback1(
      e => ReactEvent.Form.target(e)["valueAsNumber"] |> onChange,
      [onChange],
    )
    <input value=Belt_Float.toString(value) type_="number" onChange />
  }
  React.setDisplayName(make, "FloatWidget")
}

module BoolWidget = {
  @react.component
  let make = (~value: bool, ~onChange: bool => unit) => {
    let onChange = React.useCallback1(
      e => ReactEvent.Form.target(e)["checked"] |> onChange,
      [onChange],
    )
    <input type_="checkbox" onChange checked=value />
  }
  React.setDisplayName(make, "BoolWidget")
}

