type Reader<'v> = Reader of 'v

let Return v = Reader v

let runReader mx d = 
    match mx with
    | Reader v -> v d

let Bind mx f =
    match mx with
    | Reader v -> Reader (fun z -> (v z) |> f |> runReader <| z)

let (>>=) = Bind

/////////////////////////////////////////////////////////////////////////////

let greeter =
    Return (fun n -> "hello, " + n + "!") 

let calc (s:string) =
    Return (fun (n:string) -> s.Length - n.Length)

let config = "leon"

let r = runReader (greeter >>= calc) config