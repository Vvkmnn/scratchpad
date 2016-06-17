# Excel Tricks

## Hotkeys

### Calculate functions in cell for testing
```
<Command> + <=>
```

### Insert an array function

```
 <Command> + <Enter>
 ```

## Matching

### Match strings in a list
[[**Source**](http://blog.contextures.com/archives/2012/10/09/find-text-with-index-and-match/)] Match a named range by counting which cells contains a keyword in a named range (using wildcards), and matching it back to the named range. Must be used as an array function.

```
{=INDEX(Keywords,MATCH(1,COUNTIF(TargetCell,"*"&Keywords&"*"),0))}

```
