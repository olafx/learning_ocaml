let rec factors_helper r c l =
  if r = c then (c::l) else
  match r mod c with
  | 0 -> factors_helper (r/c) c (c::l)
  | _ -> factors_helper r (c+1) l

let factors n =
  match n with
  | n when n < 1 -> raise (Failure "factors of nonpositive number")
  | 1 -> [1]
  | _ -> List.rev (factors_helper n 2 [])
