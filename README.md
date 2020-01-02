# ppx-examples
This project provides the simplest setup to develop your own ppx. Also, includes handy example extensions and derivers to help you to get started.

Stack:
  * ReasonML
  * Ppxlib
  * Esy

# Commands

##### Install Dependencies
You should install your dependencies first:
```bash
$ esy
```

##### Build
Every time you make a code change in your ppx, you have to build it with this command:
```bash
$ esy build
```

### What about testing and code output?
We found that the easiest way is to use BuckleScript! Since BuckleScript transforms our ReasonML code to Javascript, we can read that JavaScript code to see our output. You can find our BuckleScript test environment in the [test_bs](https://github.com/ttinythings/ppx-examples/tree/master/test_bs) folder.

# Useful links for ppx development
### Reference and tools
References and tools that might help you.

* [AST Explorer](https://astexplorer.net/)

### Articles
Must-read articles to understand PPX and AST

* [An introduction to OCaml PPX ecosystem](https://tarides.com/blog/2019-05-09-an-introduction-to-ocaml-ppx-ecosystem)
* [Extension Points - 3 Years Later](http://rgrinberg.com/posts/extension-points-3-years-later/)
* [Extension Points - Ppxlib & Dune Update](http://rgrinberg.com/posts/extensions-points-update-1/)
* [Deriving Slowly](http://rgrinberg.com/posts/deriving-slowly/)
* [Metaquot](https://ppxlib.readthedocs.io/en/latest/ppx-for-plugin-authors.html)

### Projects to look into
You can read these projects source codes to understand how they solved their problems. Their solutions might guide you to solve your own problems.

* [ppx_sexp_value](https://github.com/janestreet/ppx_sexp_value)
