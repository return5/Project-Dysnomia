local ScanChars <const> = require('scanner.ScanChars')
local ScanTIllNewLine <const> = require('scanner.ScanTillNewLine')
local setmetatable <const> = setmetatable

local ScanComments <const> = {type = 'ScanComments'}
ScanComments.__index = ScanComments
local io = io

setmetatable(ScanComments,ScanChars)

_ENV = ScanComments

function ScanComments:scanTillNewLine(word,char)
	io.write("scan til new line\n")
	self:addToTable(char,word)
	return ScanTIllNewLine
end

--TODO fix this so it handles subtraction
function ScanComments:parseInput(word,char)
	if self:checkIfEndOfWordMatches(word,"-") then return self:scanTillNewLine(word,char) end
	self:addToTable(char,word)
	return ScanChars
end

return ScanComments
