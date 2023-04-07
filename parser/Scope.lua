
local setmetatable <const> = setmetatable

local Scope <const> = {}
Scope.__index = Scope

_ENV = {}

function Scope:new()
	self.vars[#self.vars + 1] = {}
end

function Scope:add(var)
	self.vars[#self.vars][var] = true
end

function Scope:addGlobal(var)
	self.vars[#self.vars][var] = true
	self.globalScope:add(var)
end

function Scope:close()
	self.vars[#self.vars] = nil
end

function Scope:check(var)
	for i = #self.vars,1,-1 do
		if self.vars[i][var] then
			return true
		end
	end
	if self.globalScope then
		return self.globalScope:check(var)
	end
	return false
end

function Scope:init(globalScope)
	return setmetatable({vars = {{}},globalScope = globalScope},self)
end


return Scope
