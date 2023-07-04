
local setmetatable <const> = setmetatable 

local Scope <const> = {}
Scope.__index = Scope

_ENV = Scope

function Scope:addChild(child)
	child.parent = self
	return self
end

function Scope:checkVar(var)
	if self.vars[var] then return self.vars[var] end
	if self.parent then return self.parent:checkVar(var) end
	return false
end

function Scope:addVar(var)
	self.vars[var.name] = var
	return self
end

function Scope:new(parent)
	return setmetatable({parent = parent,vars = {}},self)
end

return Scope
