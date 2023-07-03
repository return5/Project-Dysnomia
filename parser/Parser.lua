
local setmetatable <const> = setmetatable 

local Parser <const> = {}
Parser.__index = Parser

_ENV = Parser


function Parser:loopText()
	local i = 1
	while i < #self.text do

	end
end

function Parser:new(text)
	local o <const> = setmetatable({text = text,dysText = {}},self)
	return o
end

return Parser
