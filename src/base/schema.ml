(* type user = { name: string; age: int; }
type income = { proof_income: int; additional_income: int; }
type state = { user: user; income: income; } *)

module rec Schema_object : sig
  type ('t, 'field) schema = 
    | Schema_string: 'field -> (string, 'field) schema
    | Schema_number: 'field -> (int, 'field) schema
    | Schema_boolean: 'field -> (bool, 'field) schema
    | Schema_object: ('field * (module Schema_object.Object with type t = 't)) -> ('t, 'field) schema

  module type Object = sig
    type t
    type _ field

    type field_wrap = Mk_field : ('a, 'a field) schema -> field_wrap

    (* val schema: field_wrap list *)
    val schema: field_wrap array
    val get: t -> 'a field -> 'a
  end

end = Schema_object
(* 
open Schema_object

module User = struct
  type t = user

  type 'a field =
    | Name: string field
    | Age: int field

  type field_wrap = Mk_field : ('a, 'a field) schema -> field_wrap
    
  let schema = 
    [ Mk_field(Schema_number(Age));
      Mk_field(Schema_string(Name))
    ]
  let get : t -> 'a field -> 'a = fun (type value) ->
      (fun state  ->
         fun field  ->
           match field with | Name  -> state.name | Age  -> state.age : 
      t -> value field -> value) 
    
end 

 module Income = struct
  type t = income

  type _ field =
    | ProofIncome: int field
    | AdditionalIncome: int field

    type field_wrap = Mk_field : ('a, 'a field) schema -> field_wrap
     let schema = [Mk_field(Schema_number(ProofIncome)); Mk_field(Schema_number(AdditionalIncome))]
    let get : 'value . t -> 'value field -> 'value= fun (type value) ->
      (fun state  ->
         fun field  ->
           match field with | ProofIncome -> state.proof_income | AdditionalIncome  -> state.additional_income : 
      t -> value field -> value)  
end 

module State  = struct 

  type t = state

  type _ field =
    | User: user field
    | Income: income field

  type field_wrap = Mk_field : ('a, 'a field) schema -> field_wrap
  let schema = [
    Mk_field(Schema_object((User, (module User))));
    Mk_field(Schema_object((Income, (module Income))))
  ]
  let get (type a) (state: t) (f: a field): a = match f with
    | User -> state.user
    | Income -> state.income
end
let user = {name = "sd"; age = 123}
let income = {proof_income = 123; additional_income = 456}
let state = { user; income; }

 let rec schema_handler: type a. a -> (module Schema_object.Object with type t = a) -> string =
   fun (data) ->
    fun (module O: Schema_object.Object with type t = a) ->
      let handle_object_field (type f) (pair: f O.field * (module Schema_object.Object with type t = f)) =
        let field = fst pair in 
        let next_data = O.get data field in
        schema_handler next_data (snd pair) in
      let handle i : string = match i with
        | O.Mk_field (Schema_object.Schema_string(s)) -> O.get data s
        | O.Mk_field (Schema_object.Schema_number(n)) -> string_of_int (O.get data n + 1)
        | O.Mk_field (Schema_object.Schema_boolean(b)) -> b |> O.get data |> not |> string_of_bool
        | O.Mk_field (Schema_object.Schema_object(o)) -> handle_object_field o
      in List.fold_left (fun acc f -> String.concat (handle f) [" "; acc]) "" O.schema
let result = schema_handler state (module State) *)
