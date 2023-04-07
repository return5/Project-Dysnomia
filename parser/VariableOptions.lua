
local setmetatable <const> = setmetatable 
local concat <const> = table.concat
local pairs <const> = pairs

local VariableOptions <const> = {}
VariableOptions.__index = VariableOptions

_ENV = VariableOptions

function VariableOptions:getModifiers()
	local tbl <const> = {" <"}
	for k,_ in pairs(self.modifiers) do
		tbl[#tbl + 1] = k
		tbl[#tbl + 1] = ","
	end
	tbl[#tbl] = nil
	if #tbl == 0 then
		return ""
	end
	tbl[#tbl + 1] = ">"
	return concat(tbl)
end

function VariableOptions:setOption(option,value)
	self.modifiers[option] = value == nil and nil or true
end

function VariableOptions:getScope(text)
	if self.scope == "local " then
		return self.scope .. text
	end
	return text
end

function VariableOptions:SetConst()
	self.modifiers["const"] = true
end

function VariableOptions:setMutable()
	self.modifiers["const"] = nil
end

function VariableOptions:setLocal()
	self.scope = "local "
end

function VariableOptions:removeLocal()
	self.scope = "none"
end

function VariableOptions:setGlobal()
	self.scope = "global"
	self:setMutable()
end

function VariableOptions:setVar(var)
	return self:getScope(var) .. self:getModifiers()
end

function VariableOptions:reset()
	self.modifiers = {["const"] = true}
	self.modifiable = false
	self.scope = "local "
	self.varLoc = 1
end

function VariableOptions:new(modifiable,scope)
	local o <const> = setmetatable({scope = scope or "local ",modifiable = modifiable or false,modifiers = {["const"] = true},varLoc = 1},self)
	return o
end

return VariableOptions
