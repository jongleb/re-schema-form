module StringWidget =  {
    @react.component
    let make = (~value: string, ~onChange: string => ()) => {
        let onChange = React.useCallback1(
             e => ReactEvent.Form.target(e)["value"] |> onChange,
            [onChange]
        );
        <input value type_="text" onChange />
    }
}