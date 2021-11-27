let (<|>) a b =
  match (a, b) with
  | (Some(x), _) -> a
  | (_, lazy(y)) -> y