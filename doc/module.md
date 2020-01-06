
# Module

## Life cycle

``` flow
add=>start: onAttch
remove=>condition: onRemove
destroy=>end: onDestroy

nop=>operation: NOP

add->remove(yes)->destroy
remove(no)->nop
```
