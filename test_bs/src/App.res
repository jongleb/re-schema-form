
let rec renderSimpleSchema = (schema: Schema.t) => {
  switch schema {
    | Schema.String => <input type_="text"/>
    | Schema.Number => <input type_="number" />
    | Schema.Boolean => <input type_="checkbox"  />
    | Schema.Array => React.null
    | Schema.Object(list) => {
      <div style={ReactDOMStyle.make(~marginLeft="10px", ~marginTop="10px", ~border="solid 1px black", ~padding="10px", ())}>
       {
          list 
            |> Array.mapi((i, j) =>
                <div key={Belt.Int.toString(i)}>
                  {renderSimpleSchema(j)}
                </div> 
              ) 
            |> React.array
       }
      </div>
    }
  }
}

@react.component
let make = (~schema: Schema.t) => {
  <div title="test">
    <form>
      {renderSimpleSchema(schema)}
    </form>
  </div>
}