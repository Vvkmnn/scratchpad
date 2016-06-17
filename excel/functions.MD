## Hotkeys

Calculate functions in cell for testing
```
<Command> + <=>
```

Insert an array function

```
 <Command> + <Enter>
 ```

## Matching

Match a named range by count if a cell contains any of the keywords in a named range (using wildcards), and matching it back to the named range. Must be used as an array function.

[**Source**](http://blog.contextures.com/archives/2012/10/09/find-text-with-index-and-match/)

```
{=INDEX(Keywords,MATCH(1,COUNTIF(TargetCell,"*"&Keywords&"*"),0))}

```
