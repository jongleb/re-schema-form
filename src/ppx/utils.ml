let (<|>) a b =
  match (a, b) with
  | (Some(x), _) -> a
  | (_, lazy(y)) -> y

let get_attribute_or ~name label or_case needed_case = 
  let open Ppxlib.Ast_pattern in 
  let pstr_payload = pstr(pstr_eval(__)(__) ^:: (__)) in
  let attr = attribute ~name:(string name) ~payload:pstr_payload in
  let match_pattern = label_declaration_attributes (__) (__) in
  parse match_pattern Location.none ~on_error:(Fun.const or_case) label (fun l _ -> 
    l 
    |> List.find_map (fun i ->
        parse attr Location.none ~on_error:(Fun.const None) i (fun e _ _ -> Some(e))
      ) 
    |> Option.map needed_case
    |> Option.value ~default:or_case
  )