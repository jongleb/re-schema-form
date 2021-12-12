open Schema

type props<'t, 'r, 'k, 'm> = {
    field: Schema.t<'t, 'r, 'k, 'm>,
    onChange: 'k => unit,
    formData: 'k,
    widget: option<module(Widgets.Widget with type t = 'k)>
  }

  @obj
  external makeProps: (
    ~field: Schema.t<'t, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    ~widget: option<module(Widgets.Widget with type t = 'k)>,
    unit,
  ) => props<'t, 'r, 'k, 'm> = ""

  let make:
    type t r k m. props<t, r, k, m> => React.element =
    (props: props<t, r, k, m>) => {
      switch props.field {
      | SObject(arr) =>
        <ObjectRender
          formData=props.formData schema=arr onChange=props.onChange
        />
      | Primitive(_) =>
        <PrimitiveRender
          field=props.field onChange=props.onChange formData=props.formData
        />
      | SArr(_) => React.string("3")
      | _ => React.string("")
      }
    }

  let () = React.setDisplayName(make, "SwitchRender")