example of dys files and their syntax

## example 1
- files: ``example1.dys``
- example include update operators, local and global functions, and various function declarations.
- to run, try: ``lua dysnomia.lua examples/example1/example1.dys``
  - to view the lua output, try: ``lua dysnomia.lua -perm examples/example1/example1.dys``

## example 2
- files: ``example2.dys`` ``MyClass.dys`` ``PrsonClass.dys``
- example includes instatiating an object from a class which includes one layer of inheritance.
  - ``example1.dys`` includes an example of instantiating an object from a class.
  - ``MyClass.dys`` example of a class with a user provided method and constructor.
  - ``PersonClass.dys`` example of a class which provides a default constructor and no methods.
- to run, try: ``lua dysnomia.lua examples/example2/example2.dys``
  - to view the lua output, try: ``lua dysnomia.lua -perm examples/example2/example2.dys``
