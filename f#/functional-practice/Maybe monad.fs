type Maybe<'a> =
| Just of 'a
| Nothing
 
let Return x = Just x
 
let Bind mx f =
match mx with
| Just x -> f x
| Nothing -> Nothing
 
let (>>=) = Bind