
local setmetatable <const> = setmetatable
local parent <const> = {}
parent.__index = parent
_ENV = parent

function parent:new(a,b)
	return setmetatable({a = a,b = b},self)
end
return parent



local setmetatable <const> = setmetatable
local myClass <const> = {}
myClass.__index = myClass
setmetatable(myClass,parent)
_ENV = myClass

	self:myMeth(7,7)

	function myClass:myMeth(k,j) end

	self:myMeth(4,5)

	function myClass:new(a,b,c)
		local __obj__ = setmetatable(parent:new(a,b),self)
		__obj__:__constructor__(a,b,c)
		return __obj__
	end

	function myClass:__constructor__(a,b,c)
		self.c = c
	end

return myClass

