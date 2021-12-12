open Schema


@react.component
  let make = (
    ~formData: 't,
    ~schema: array<schemaListItem<'t, 'm>>,
    ~onChange: 't => unit,
  ) => {
    <React.Fragment>
      {schema
      |> Array.map((SchemaListItem(field)) =>
        <ReRender obj=formData field onChange />
      )
      |> React.array}
    </React.Fragment>
  }
  let () = React.setDisplayName(make, "ObjectRender")
