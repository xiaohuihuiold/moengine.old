# Module

## Life cycle

![module_lifecycle](mermaid/module_lifecycle.svg)

```mermaid
graph TD

attach((onAttach))
remove{onRemove}
destroy((onDestroy))
nop(NOP)

attach-->remove
remove--true-->destroy
remove--false-->nop
```
