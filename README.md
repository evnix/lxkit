# lxkit
Lua Cross Platform UI Toolkit


##### Instructions:

**For Windows**

Build a static Library from:

https://github.com/andlabs/libui

After that,

Compile DLL from: 

https://github.com/zhaozg/lui

(The above are not really straight-forward)

Place the .dll in this directory and name it lui.dll

Run 
```
lua testLoadXMLUI.lua exampleXML/loginForm.xml
```
