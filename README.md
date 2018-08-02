# Modolize
An attempt at providing a clean python like interface to filein maxscript files using pure Maxscript. Very draft implementation, a complete rewrite is on its way.. poc is in remodo.ms

```maxscript
modo = Modolize()
modo.set_basePath @"C:\Work\code\3ds\maxscript\Modolize"
modo.filein "test.module_test.anotherModule.hello"
modo.filein "test.hello"
```
