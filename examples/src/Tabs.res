
type selectedExample = First | Second | Third | Fourth | Fifth

@val @scope(("window", "location"))
external hash: string = "hash"

@react.component
let make = () => {
    let (selected, setSelected) = React.useState(_ => 
            switch hash {
                | "#1" => Some(First)
                | "#2" => Some(Second)
                | "#3" => Some(Third)
                | "#4" => Some(Fourth)
                | "#5" => Some(Fifth)
                | _ => None
            }
        );

    <div className="container">
        <h1>{React.string("Examples")}</h1>
        <a className="button" onClick=(_ => setSelected(_ => Some(First)))>{React.string("Simple example")}</a>
        <a className="button" onClick=(_ => setSelected(_ => Some(Second)))>{React.string("Custom render by type")}</a>
        <a className="button" onClick=(_ => setSelected(_ => Some(Third)))>{React.string("Custom render concrete field")}</a>
        <a className="button" onClick=(_ => setSelected(_ => Some(Fourth)))>{React.string("Field wrapper")}</a>
        <a className="button" onClick=(_ => setSelected(_ => Some(Fifth)))>{React.string("Option(Nullable in imperative) render")}</a>
        {
            switch selected {
                | Some(e) => switch e {
                    | First => <App/>
                    | Second => <CustomRenderByType />
                    | Third => <ConcreteFieldRender />
                    | Fourth => <FieldWrapperExample />
                    | Fifth => <NullableField />
                }
                | _ => React.null
            }
        }
    </div>
} 