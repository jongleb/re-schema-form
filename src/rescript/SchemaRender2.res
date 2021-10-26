open Schema


@react.component
let make = (
  ~field: Schema.t<'t, 'r, 'k>,
  ~onChange: 'r => unit,
  ~formData: 'k,
) => {
  <SwitchRender field onChange formData />
}
