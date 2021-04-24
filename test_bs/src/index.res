open Schema

module StateSchema = %schema(
 type another_one = {
   abcd: string,
 }
 type state = {
   email: string,
   age: int,
   test2: string,
 };
);

