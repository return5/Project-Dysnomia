
Project [Dysnomia](https://en.wikipedia.org/wiki/Dysnomia_(moon)): adding syntax and features on top of Lua 5.4  
The stated goal of this project is to build on top of Lua 5.4 with new syntax, features, and enhancements.
currently this is a work in progress.
  
## requirements
 - Lua >= 5.4

## running
simply pass into dysnomia any dysnomia flags and the file which serves at the starting point of your application.  
dysnomia will parse through the ```.dys``` files and (by default) run the Lua program.     
sample command to run dysnomia:  
``lua dysnomia.lua [flags] [main file]``  

## dysnomia flags
a list of the flags and command line options for dysnomia:  
 - ```-parse```  only parse through files, do not run the program after parsing.
 - ```-os [os name]```  enter the os type you are using, such as linux or windows.
 - ```-sep [separator]```  the file separator used by your OS for filepaths.
- ```-nl [char(s)]```  enter the newline character(s) which your OS uses.
 - ```-perm```  Do not remove generated files after running.
 - ```-temp```  remove all generated files after running.(default)
 - ```-help```  print help screen.  

## features, syntax changed, and enhancements
- update operators:
  - ```+=``` 
  - ```-=``` 
  - ```/=``` 
  - ```*=```
- by default, all vars are local and const.
- ```global``` keyword. declares a variable or function to not be local
  - ```myVar <global> = 5```
  - ``global function myFunc() return 5 end``
- ```mutable``` keyword. declares a variable is mutable.
  - ```myVar <mutable> = 6```
- ```class``` keyword. declares a class. [(please see class section)](#class)
  - ```class myClass(var1,var12,var3) endCLass```
- ```:>``` used to declare inheritance of class. [(please see class section)](#class)
  - ```class childClass() :> parentClass endClass```
- ```super()``` calls parent constructor inside of class. [(please see class section)](#class)
  - ``super(var1,var2)``
- ``record`` immutable collection for holding data. [(please see records section)](#records)
  - ```record MyRecord(a,b,c,d) {}```

## class
offers class declaration inspired by java records.  
basic syntax is: class keyword followed by class name. then include any parameters to pass into constructor and a parent class if it is a child class. finally needs opening and closing brackets:    
```class MyChildClass(param1,param2) :> MyParentClass endClass```
- if no constructor is provided, then one will be created automatically.  
  - constructor names scanned for: ``init`` ``new`` and the ``name of the class.``
- you may declare class methods inside the brackets:
  - ```function myMethod(a,b) end```
    - this will be replaced by parser as: ```function MyClass:myMethod(a,b) end```
- to access class variables you use the ```self``` keyword
  - ```self.myVar = 6```
- ```self``` is not needed when accessing class methods
  - ```myMethod(5,6)``` 
    - translates to: ```self:myMethod(5,6)```
- ``super`` calls the parent constructor. only needed if you provide a constructor and your class also inherents from a parent class.
  - ```super(var1,var2) ```
- ```:>``` used in class declaration to declare a parent class.
- new objects can be instantiated from class by calling class name as a function.  
  - ```myObj = MyClass(var1,var2)```
- ``local`` declares a function to be local.
  - ```local function myFun(a,b) end```
- ``global`` declars that a function is global in scope.
  - ``global function myFunc(a,b) end``
- note: spaces are required between keywords in declaration. spaces should not be included between parameters in declaration.
- note: classes need to be declared inside their own separate file.

## records
An immutable object for storing data. declare the number and names of the parameters. call it like a function to generate objects from it.
````  
record MyRecord(a,b) endRec
rec = MyRecord(5,6)
````
- unlike classes, they do not have to be declared inside their own file.

## considerations
to keep the parser simpler and easier to write, there are a few things to keep in mind when writing dysnomia syntax.
- put spaces around any ```=``` when it comes to variable declarations. ``myVar = 5``
  - this rule can be disregarded when it comes to table constructs ```myTbl = {a=4,b=6,c=7}``` is valid dysnomia syntax.
- put spaces around update operators. ```i += 1``` 
- when declaring classes, the keywords in class declarations should have spaces around them. the parameters, if any, should not have spaces.
  - ```class MyClass(par1,par2,par3) :> MyParentClass endClass```
- the `(` of function declarations and calls should not have a space before it.
- classes need to be declared inside their own separate file.
- function parameters should not include spaces.
  - ```function myFunc(p1,p2) end``` and also ``myFunc(1,2)``
- for declaring multiple variables on the same line, do not include a space between them
  - ```var1,var2,var3 = 5```
- for best results, declare them separately and use a comma between.
  - ````var1 = 5;var2 = 5;var3 = 5````
- for simplicity reasons, the readability of the outputted lua code wasnt a high priority. as such, it doesnt follow coding conventions in a readable manner.

## examples
  please see the ``eamples`` directory for examples of dysnomia.

## TODO
- [x] add immutable records
- [ ] add lambda constructs
- [ ] add built in data types
- [ ] add built-in functions and libraries
- [ ] test on windows
- [ ] test on Mac
- [ ] do more edge case testing
- [ ] syntax highlighter
- [ ] syntax checking and error handling