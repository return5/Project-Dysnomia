local setmetatable <const> = setmetatable

local DysText <const> = {type = 'DysText'}
DysText.__index = DysText

_ENV = DysText

function DysText:write(arg)
	self.text[#self.text + 1] = arg
	return self
end

function DysText:writeTwoArgs(arg1,arg2)
	self:write(arg1):write(arg2)
	return self
end

function DysText:writeThreeArgs(arg1,arg2,arg3)
	self:writeTwoArgs(arg1,arg2):write(arg3)
	return self
end

function DysText:getDysText()
	return self.text
end

function DysText:new()
	return setmetatable({text = {}},self)
end


return DysText
