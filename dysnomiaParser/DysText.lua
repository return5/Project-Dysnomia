local setmetatable <const> = setmetatable
local remove <const> = table.remove


local DysText <const> = {type = 'DysText'}
DysText.__index = DysText

_ENV = DysText

function DysText:eraseEndingText()
	remove(self.text)
end

function DysText:loopBackUntil(matchFunc,func)
	local i = #self.text
	while i > 0 and not matchFunc(self.text[i]) do
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
	self.text[#self.text + 1] = arg1
	self.text[#self.text + 1] = arg2
	return self
end

function DysText:writeThreeArgs(arg1,arg2,arg3)
	self.text[#self.text + 1] = arg1
	self.text[#self.text + 1] = arg2
	self.text[#self.text + 1] = arg3
	return self
end

function DysText:writeFourArgs(arg1,arg2,arg3,arg4)
	self.text[#self.text + 1] = arg1
	self.text[#self.text + 1] = arg2
	self.text[#self.text + 1] = arg3
	self.text[#self.text + 1] = arg4
	return self
end

function DysText:writeFiveArgs(arg1,arg2,arg3,arg4,arg5)
	self.text[#self.text + 1] = arg1
	self.text[#self.text + 1] = arg2
	self.text[#self.text + 1] = arg3
	self.text[#self.text + 1] = arg4
	self.text[#self.text + 1] = arg5
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

function DysText:setDysText(newDys)
	self.text = newDys
	return self
end

function DysText:new()
	return setmetatable({text = {}},self)
end


return DysText

