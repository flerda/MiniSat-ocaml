(**************************************************************************)
(*  debcudf - Debian Packages file to CUDF conversion tool                *)
(*  Copyright (C) 2009  Pietro Abate <pietro.abate@pps.jussieu.fr>        *)
(*                                                                        *)
(*  This library is free software: you can redistribute it and/or modify  *)
(*  it under the terms of the GNU Lesser General Public License as        *)
(*  published by the Free Software Foundation, either version 3 of the    *)
(*  License, or (at your option) any later version.  A special linking    *)
(*  exception to the GNU Lesser General Public License applies to this    *)
(*  library, see the COPYING file for more information.                   *)
(**************************************************************************)

open Ocamlbuild_plugin
open Command (* no longer needed for OCaml >= 3.10.2 *)

let clibs = [("minisat","minisat")]

(* these functions are not really officially exported *)
let run_and_read = Ocamlbuild_pack.My_unix.run_and_read
let blank_sep_strings = Ocamlbuild_pack.Lexers.blank_sep_strings

(* this lists all supported packages *)
let find_packages () =
  blank_sep_strings &
    Lexing.from_string &
      run_and_read "ocamlfind list | cut -d' ' -f1"

(* this is supposed to list available syntaxes, but I don't know how to do it. *)
let find_syntaxes () = ["camlp4o"; "camlp4r"]

(* ocamlfind command *)
let ocamlfind x = S[A"ocamlfind"; x]

let _ = dispatch begin function
   | Before_options ->
       (* by using Before_options one let command line options have an higher priority *)
       (* on the contrary using After_options will guarantee to have the higher priority *)

       (* override default commands by ocamlfind ones *)
       Options.ocamlc     := ocamlfind & A"ocamlc";
       Options.ocamlopt   := ocamlfind & A"ocamlopt";
       Options.ocamldep   := ocamlfind & A"ocamldep";
       Options.ocamldoc   := ocamlfind & A"ocamldoc";
       Options.ocamlmktop := ocamlfind & A"ocamlmktop"

   | After_rules ->

       (* When one link an OCaml library/binary/package, one should use -linkpkg *)
       flag ["ocaml"; "link"] & A"-linkpkg";
       flag ["c"; "compile"; "g++"] (S[A"-cc"; A"g++"; A"-ccopt"; A"-fPIC"]);
       flag ["cc"; "compile"; "g++"] (S[A"-cc"; A"g++"; A"-ccopt"; A"-fPIC"]);
       (* flag ["ocamlmklib"] (S[A"-lminisat"; A"-oc"; A"minisat_stubs" ]); *)

       (* For each ocamlfind package one inject the -package option when
        * compiling, computing dependencies, generating documentation and
        * linking. *)
       List.iter begin fun pkg ->
         flag ["ocaml"; "compile";  "pkg_"^pkg] & S[A"-package"; A pkg];
         flag ["ocaml"; "ocamldep"; "pkg_"^pkg] & S[A"-package"; A pkg];
         flag ["ocaml"; "doc";      "pkg_"^pkg] & S[A"-package"; A pkg];
         flag ["ocaml"; "link";     "pkg_"^pkg] & S[A"-package"; A pkg];
       end (find_packages ());

       (* Like -package but for extensions syntax. Morover -syntax is useless
        * when linking. *)
       List.iter begin fun syntax ->
         flag ["ocaml"; "compile";  "syntax_"^syntax] & S[A"-syntax"; A syntax];
         flag ["ocaml"; "ocamldep"; "syntax_"^syntax] & S[A"-syntax"; A syntax];
         flag ["ocaml"; "doc";      "syntax_"^syntax] & S[A"-syntax"; A syntax];
       end (find_syntaxes ());

       List.iter begin fun (lib,dir) ->
         flag ["ocaml"; "link"; "c_use_"^lib; "byte"]
         (S[A"-custom"; (* A"-cclib"; A"-lstdc++"; *) A"-ccopt"; A("-L"^lib); A"-cclib"; A("-l"^lib)]);

         flag ["ocaml"; "link"; "c_use_"^lib; "native"]
         (S[A"-cclib"; A"-lstdc++"; A"-ccopt"; A("-L"^lib); A"-cclib"; A("-l"^lib)]);

         flag [ "byte"; "library"; "link" ]
         (S[A"-dllib"; A("-l"^lib); A"-cclib"; A("-l"^lib^"stubs")]);

         flag [ "native"; "library"; "link" ]
         (S[A"-cclib"; A("-l"^lib); A"-cclib"; A("-l"^lib^"_stubs")]);

         (* Make sure the C pieces is built... *)
         if Sys.file_exists dir then begin
           dep  ["ocaml"; "compile"; "c_use_"^lib] [dir^"/lib"^lib^"_stubs.a"];
           dep  ["ocaml"; "link"; "c_use_"^lib] [dir^"/lib"^lib^"_stubs.a"];
         end
         else begin
           dep  ["ocaml"; "compile"; "c_use_"^lib] ["lib"^lib^"_stubs.a"];
           dep  ["ocaml"; "link"; "c_use_"^lib] ["lib"^lib^"_stubs.a"];
         end

       end clibs ;

       (* The default "thread" tag is not compatible with ocamlfind.
          Indeed, the default rules add the "threads.cma" or "threads.cmxa"
          options when using this tag. When using the "-linkpkg" option with
          ocamlfind, this module will then be added twice on the command line.
       
          To solve this, one approach is to add the "-thread" option when using
          the "threads" package using the previous plugin.
        *)
       flag ["ocaml"; "pkg_threads"; "compile"] (S[A "-thread"]);
       flag ["ocaml"; "pkg_threads"; "link"] (S[A "-thread"]);
       
       (** Rule for native dynlinkable plugins *)
       rule ".cmxa.cmxs" ~prod:"%.cmxs" ~dep:"%.cmxa"
       (fun env _ ->
         let cmxs = Px (env "%.cmxs") and cmxa = P (env "%.cmxa") in
         Cmd (S [!Options.ocamlopt ; A"-linkall" ; A"-shared" ; A"-o" ; cmxs ; cmxa])
       );

   | _ -> ()
end
