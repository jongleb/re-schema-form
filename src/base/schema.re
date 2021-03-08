type schemaType = | String | Number | Object | Array | Boolean;

type t = {
    _type: schemaType,
    name: string,
    properties: list<t>
}