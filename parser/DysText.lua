local setmetatable <const> = setmetatable
local remove <const> = table.remove
local match <const> = string.match

local DysText <const> = {type = 'DysText'}
DysText.__index = DysText

_ENV = DysText

function DysText:eraseEndingText()
	remove(self.text)
end

function DysText:loopBackUntil(endingChar,func)
	local i = #self.text
	while i > 0 and not match(self.text[i],endingChar) do
		func(self)
		i = i - 1
	end
	return self
end

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

function DysText:writeFourArgs(arg1,arg2,arg3,arg4)
	self:writeThreeArgs(arg1,arg2,arg3):write(arg4)
	return self
end

function DysText:writeFiveArgs(arg1,arg2,arg3,arg4,arg5)
	self:writeFourArgs(arg1,arg2,arg3,arg4):write(arg5)
	return self
end

function DysText:getDysText()
	return self.text
end

function DysText:getLength()
	return #self.text
end

function DysText:getAt(index)
	return self.text[index]
end

function DysText:getCurrent()
	return self.text[#self.text]
end

function DysText:replaceTextAt(text,index)
	self.text[index] = text
	return self
end

function DysText:new()
	return setmetatable({text = {}},self)
end


return DysText
