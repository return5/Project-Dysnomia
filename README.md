
Project [Dysnomia](https://en.wikipedia.org/wiki/Dysnomia_(moon)): adding syntax and features on top of Lua 5.4 

- The stated goal of this project is to build on top of Lua 5.4 with new syntax, features, and enhancements.   

  
- Takes dysnomia files and cross-compiles them into syntactically correct lua 5.4 files.  
  

- this repo is a huge rewrite of my previous attempt.   


- (currently this is a work in progress.)

- this project has been rewritten entirley in dysnomia. [check it out here](https://github.com/return5/dysnomia)
  
## requirements
 - Lua >= 5.4

## installing
the easiest way to install is to grab the single file version of it [here](https://gist.github.com/return5/6e95741cb526262d149e69bb880e45f7). (checkout [squish](https://code.matthewwild.co.uk/squish/summary))
you can then place theat file anywhere you want, maybe even make an alias or put it on your system path for easy use.  

alternatively download the sourceode of thei project and run ``lua dysnomia.lua``

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
- ``-skip [file(s)]`` comma separated list of files to skip over.
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
- ```var``` keyword. declares a variable.
  - ``var myVariable``
- ```global``` keyword. declares a variable, Record, or function to not be local
  - ```var myVar <global> = 5```
  - ``global function myFunc() return 5 end``
  - ``global Record myRecord``
- ```mutable``` keyword. declares a variable is mutable.
  - ```var myVar <mutable> = 6```
- ```class``` keyword. declares a class. [(please see class section)](#class)
  - ```class myClass(var1,var12,var3) endCLass```
- ```:>``` used to declare inheritance of class. [(please see class section)](#class)
  - ```class childClass() :> parentClass endClass```
- ```super()``` calls parent constructor inside of class. [(please see class section)](#class)
  - ``super(var1,var2)``
- ``record`` immutable collection for holding data. [(please see records section)](#records)
  - ```record MyRecord(a,b,c,d) {}```
- ``lambdas`` shorthand syntax for declaring an anonymous function. [(please see lambda section)](#lambda)
  - ``a -> a + 5``
- ```#skipRequire``` add this in a comment on the line directly above any ```require``` statement to tell dysnomia to ignore that file. dysnomia will not attempt to parse the file included in the require.
  ```
    -- #skipRequire
    var myRequire = require('myFile') --dysnomia will not scan this file.
  ```
- ```#skipfile``` ```#skipFile``` ```#Skipfile``` ```#SkipFile``` add one of these in a comment to tell dysnomia to skip scanning and parsing of this file.

## class
offers class declaration inspired by java records.  
basic syntax is: class keyword followed by class name.  
then include any parameters to pass into constructor and a parent class if it is a child class.  
finally, close with ``endClass``:    
```class MyChildClass(param1,param2) :> MyParentClass endClass```
- if no constructor is provided, then one will be created automatically.  
- ``constructor`` declares a class constructor.
  - ```constructor(param1,param2) end```
- ``super`` calls the parent constructor. needs to be included if you include a constructor and class has a parent class.
  - ``super(param1)``
- you may declare class methods inside the class:
  - ```method myMethod(a,b) end```
- ``static`` declares a method to be static rather than an instance method.
    - ```static method myMethod()```
- to access class variables you use the ```self``` keyword
  - ```self.myVar = 6```
- ```self``` is not needed when accessing class methods
  - ```myMethod(5,6)``` 
    - translates to: ```self:myMethod(5,6)```
- ```:>``` used in class declaration to declare a parent class.
- new objects can be instantiated from class by calling the ``new`` function on the class.  
  - ```var myObj = MyClass:new(var1,var2)```
- ``local`` declares a function to be local.
  - ```local function myFun(a,b) end```
- ``global`` declares that a function is global in scope.
  - ``global function myFunc(a,b) end``
- note: spaces are required between keywords in declaration.
- note: classes need to be declared inside their own separate file.

## records
An immutable object for storing data. declare the number and names of the parameters. call it like a function to generate objects from it.
````  
record MyRecord(a,b) endRec
var rec = MyRecord(5,6)
````
- unlike classes, they do not have to be declared inside their own file.

## lambda
A shorthand syntax for declaring an anonymous function.
- a single parameter, single statement can be declared as:
  - ```a -> a+5```
  - this is, a function which takes in one input 'a' and returns 'a' + 5.  equivalent to the lua code:
    - ``function(a) return a + 5 end``
  - for single input, no parenthesis are needed.
  - for single statement body, no brackets are used nor is 'return' used.  
  

- a no parameter lambda can be declared as:
  - ```() -> 5```
  - this, a function which takes no input and returns the number 5.
  - for zero inputs, parenthesis must be used.  
  

- multiple input lambda can be declared as:
  - ``(a,b) -> a+b``
  - that is, a function which takes two inputs and returns their values added together.
  - for multiple inputs, parenthesis must be used.  
  

- multiple statement lambdas:
  - ```(a,b) -> { if a < 5 then return b end return a}```
  - a function which takes in two inputs, if the first is less than 5 then return second input, otherwise return the first argument.
  - for multi-statement lambdas, curly brackets and 'return' statement must be used.  


- just as an FYI, lambdas arnt picky about spaces.
  - ``a->{if a<5 then return 5 end return 5} ``
  - perfectly valid to have spaces between parameters, '->', curly brackets, etc.   


## considerations
to keep the parser simpler and easier to write, there are a few things to keep in mind when writing dysnomia syntax.
- when declaring classes, the keywords in class declarations should have spaces around them. the parameters, if any, should not have spaces.
  - ```class MyClass(par1,par2,par3) :> MyParentClass endClass```
- classes need to be declared inside their own separate file.
- for simplicity reasons, the out putted lua code isnt as readable nor optimized as handwritten code.  
  it is entirely readable, but may not be formatted well. under normal use cases this isnt a problem as it would only need to be read in a debugging session.

## dysnomiaExamples
  please see the ``dysnomiaExamples`` directory for dysnomiaExamples of dysnomia.

## Lua features not currently supported
as a superset of Lua, all  Lua features should be supported. If it is valid Lua code then it should be valid Dysnomia code. 
currently the parser does not support the follow lua features:
  - Multi-line strings  
  - Multi-line comments  
  - strings quoted with double brackets: [[ this is a valid lua string, but not a valid dysnomia string ]]
