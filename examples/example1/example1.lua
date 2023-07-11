
--create a local constant variable 'name'
local name <const> = "example 1"


--create a local function. no need for local keyword unless you want it.
local function printName()
	io.write("name is: ",name,"\n")
	printGlobal()
end

--declare a global function
function printGlobal()
	io.write("global is: ",globalVar,"\n")
end

--declare a global variable 'globalVar'
globalVar = "dysnomia is great!"

local function printUpdate()
	--create a local mutable variable 'i'
	local i = 1
	i = i + 2  -- increase i by 2
	io.write("after update 'i' is: ",i,"\n")
end

printName()
printUpdate()

