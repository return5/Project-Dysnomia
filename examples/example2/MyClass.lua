local PersonClass <const> = require ( 'examples.example2.PersonClass' ) 
 
   local MyClass <const> = {}
 name,age,sex,phoneNumber ) :> PersonClass { 
 function print ( ) 
 return "name: " .. self.name .. ". age: " .. self.age .. ". sex: " .. self.sex .. ". phone number: " .. self.phoneNumber 
 end 
 
 function MyClass ( name,age,sex,phoneNumber ) 
 super ( name,age,sex ) 
 self.phoneNumber = phoneNumber 
 end 
 } 
 
 
 
