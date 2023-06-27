local MyClass <const> = require ( 'examples.example2.MyClass' ) 
 
 local function main ( ) 
 io.write ( "running example.dys\n" ) 
 local myObj <const> = MyClass ( "return5","unknown","yes,please","1800-youSuck" ) 
 io.write ( myObj:print ( ) ,"\n" ) 
 end 
 
 main ( ) 
