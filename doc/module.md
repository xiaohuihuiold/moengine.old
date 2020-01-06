
# Module

## Life cycle

```flow
attach=>start: onAttch
remove=>condition: onRemove
destroy=>end: onDestroy

nop=>operation: NOP

attach->remove(yes)->destroy
remove(no)->nop
```
