open Widgets

// better use https://github.com/hannesm/gmap
type customWidgets = {
  boolWidget: option<module(Widget with type t = bool)>,
  floatWidget: option<module(Widget with type t = float)>,
  intWidget: option<module(Widget with type t = int)>,
  stringWidget: option<module(Widget with type t = string)>,
}

let defaultValue = {
  boolWidget: None,
  floatWidget: None,
  intWidget: None,
  stringWidget: None,
}

let context: React.Context.t<customWidgets> = React.createContext(defaultValue)

module Provider = {
  let provider = React.Context.provider(context)

  @react.component
  let make = (~value, ~children) => {
    React.createElement(provider, {"value": value, "children": children})
  }
}
