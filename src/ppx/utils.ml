let (<|>) a b =
  match (a, b) with
  | (Some(x), _) -> a
  | (_, lazy(y)) -> y

let get_attribute_or label ~name or_case needed_case = 
  let open Ppxlib.Ast_pattern in 
  let pstr_payload = pstr(pstr_eval(__)(__) ^:: (__)) in
  let attr = attribute ~name:(string(name)) ~payload:pstr_payload ^:: (__) in
  let match_pattern = label_declaration_attributes (attr) (__) in 
  parse match_pattern Location.none ~on_error:(fun () -> or_case) label (fun e _ _ _ _ -> needed_case e)  