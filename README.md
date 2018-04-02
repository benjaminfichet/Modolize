# Modolize
An attempt at providing a clean python like interface to filein maxscript files using pure Maxscript

```maxscript
m = Modulo()
m.init (@"C:\Work\code\3ds\maxscript\Modolize\")
m.file_in "module_test.filetest"
m.file_in "module_test.anotherModule.hello"
m.file_in "test"
```