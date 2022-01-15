open UiSchema
open UiFields
open MutualTypes

module Make = (Render: SwitchRender): SchemaRender => {
  type props<'t, 'r, 'k, 'm> = {
    field: Schema.t<'t, 'r, 'k, 'm>,
    onChange: 'k => unit,
    formData: 'k,
    uiSchema: module(FieldUiSchema with type t = 'k),
    meta: option<'m>,
    fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
    key: string,
  }

  @obj
  external makeProps: (
    ~field: Schema.t<'t, 'r, 'k, 'm>,
    ~onChange: 'k => unit,
    ~formData: 'k,
    ~uiSchema: module(FieldUiSchema with type t = 'k),
    ~meta: option<'m>,
    ~fieldTemplate: option<module(FieldTemplate with type m = 'm)>,
    ~key: string,
    unit,
  ) => props<'t, 'r, 'k, 'm> = ""

  let make:
    type t r k m. React.component<props<t, r, k, m>> =
    (props: props<t, r, k, m>) => {
      let module(UiSchema: FieldUiSchema with type t = k) = props.uiSchema
      let switchRender =
        <Render
          field=props.field
          onChange=props.onChange
          formData=props.formData
          widget=UiSchema.widget
          meta=props.meta
          fieldTemplate=props.fieldTemplate
        />
      let withUiField = switch UiSchema.field {
      | Some(module(UiField: UiField with type t = k)) =>
        <UiField value=props.formData onChange=props.onChange> {switchRender} </UiField>
      | _ => switchRender
      }
      switch props.fieldTemplate {
      | Some(module(Field: FieldTemplate with type m = m)) =>
        <Field value=props.formData onChange=props.onChange meta=props.meta> {withUiField} </Field>
      | _ => withUiField
      }
    }
  let () = React.setDisplayName(make, "SchemaRender")
}
