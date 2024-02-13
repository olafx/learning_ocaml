let fac_error_msg = "factorial of negative number"

let rec fac n =
  match n with
  | n when n < 0 -> raise (Failure fac_error_msg)
  | 0 | 1 -> 1
  | _ -> n*fac(n-1)
