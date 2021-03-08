
// open Schema_render_base;

module User = {
  [@deriving schema]
  type my_typ = {
    foo: int,
  }; 
};

// Js.log(User.Schema.schema);