open Migrate_parsetree;

let argv =
  switch (Sys.argv |> Array.to_list) {
  | [program, ...rest] =>
    switch (List.rev(rest)) {
    | [output_file, input_file, ...args] =>
      List.concat([
        [program],
        List.rev(args),
        [input_file, "-o", output_file, "--dump-ast"],
      ])
      |> Array.of_list
    | _ => Sys.argv
    }
  | _ => Sys.argv
  };

let () = Driver.run_main(~argv, ());