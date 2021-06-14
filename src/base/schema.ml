type user = { name: string; age: int; middleName: string option }
type income = { proof_income: int; additional_income: int; }
type state = { user: user; income: income; }


module type FieldRender = sig
  type t
end  

module rec Schema_object : sig

  type ('t, 'field) schema = 
    | Schema_string: 'field -> (string, 'field) schema
    | Schema_number: 'field -> (int, 'field) schema
    | Schema_boolean: 'field -> (bool, 'field) schema
    | Schema_object: ('field * (module Schema_object.Object with type t = 't)) -> ('t, 'field) schema

  module type Object = sig
    type t
    type _ field

    type field_wrap = 
      | Mk_field : ('a, 'a field) schema -> field_wrap
      | Mk_nullable_field : ('a, 'a option field) schema -> field_wrap


    (* val schema: field_wrap list *)
    val schema: field_wrap array
    val get: t -> 'a field -> 'a
    (* val set: t -> 'a field -> 'a -> t *)
  end

  module type Schema_config = sig

    include Object

    type field_render = Mk_field_render : ((('a, 'a field) schema) * (module FieldRender with type t = 'a)) -> field_render 
    val get_field_render: 'a field -> (module FieldRender with type t = 'a) option
  end  

end = Schema_object


open Schema_object

module User = struct
  type t = user

  type 'a field =
    | Name: string field
    | Age: int field
    | MiddleName: string option field

  type field_wrap = 
    | Mk_field : ('a, 'a field) schema -> field_wrap
    | Mk_nullable_field : ('a, 'a option field) schema -> field_wrap
    
  let schema = 
    [ Mk_field(Schema_number(Age));
      Mk_field(Schema_string(Name));
      Mk_nullable_field(Schema_string(MiddleName));
    ]
  let get : t -> 'a field -> 'a = fun (type value) ->
      (fun state  ->
         fun field  ->
           match field with 
            | Name  -> state.name 
            | Age  -> state.age
            | MiddleName  -> state.middleName : 
      t -> value field -> value) 
    
end

module NameRender = struct
  type t = string
end 

module MiddleNameRender = struct
  type t = string option
end 

module User_config = struct
  
  include User

  type field_render = Mk_field_render : ('a field * (module FieldRender with type t = 'a)) -> field_render

  type field_renders = field_render array
  let field_renders: field_renders = [| 
    Mk_field_render(Name, (module NameRender));
    Mk_field_render(MiddleName, (module MiddleNameRender))
  |]

  type (_,_) eq = Eq : ('a, 'a) eq

  let field_eq (type a) (type b) (a: a field) (b: b field): (a, b) eq option = 
    match (a, b) with
      | Name, Name -> Some Eq
      | Age, Age -> Some Eq
      | MiddleName, MiddleName -> Some Eq
      | _ -> None
  
  let get_dyn : type a. a field -> field_render -> (module FieldRender with type t = a) option =
    fun a (Mk_field_render(b, x)) ->
      match field_eq a b with
        | None -> None
        | Some Eq -> Some x  

  let get_field_render f =
    let rec loop (l: field_renders) = match Array.length l with
      | 0 -> None
      | _ -> 
        let sub_cnt = Array.length l - 1 in
        match get_dyn f l.(0) with 
          | None -> loop (Array.sub l 1 sub_cnt)
          | v -> v
        in           
        loop field_renders 
      
end  
(*
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