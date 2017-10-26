type Writer<'d, 'v> = Writer of 'd * 'v
    
let Tell d f = f d

let Return v = fun d -> Writer(d,v)

let Join d mx =
    match mx with
    | Writer(x:string,v) -> Writer(d+x, v)

let Bind mx f = 
    match mx with
    | Writer(d,v) -> f v |> Join d

let runWriter mx =
    match mx with
    | Writer(d,v) -> d,v

let (>>=) = Bind

/////////////////////////////////////////////////////////////////////////////

let half x = 
    Tell ( sprintf "I just halved %d ! " x ) <| Return ( x / 2 )

let log, result = half 8 >>= half |> runWriter

printfn "Log: %s" log
printfn "Result: %d" result