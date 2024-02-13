let n = 14
let n_fac = Irulan.Combinatorics.fac n
let n_factors = Irulan.Factorization.factors n_fac

let rec print_int_list l =
  match l with
  | [] -> ()
  | l::r -> Printf.printf (if List.length r = 0 then "%d" else "%d ") l; print_int_list r

let () =
  Printf.printf "factors of %d!\n" n;
  print_int_list n_factors; print_string "\n"
