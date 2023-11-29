local ScanChars <const> = require('Scanner.ScanChars')
local ScanTIllNewLine <const> = require('scanner.ScanTillNewLine')
local setmetatable <const> = setmetatable

local ScanComments <const> = {type = 'ScanComments'}
ScanComments.__index = ScanComments

setmetatable(ScanComments,ScanChars)

_ENV = ScanComments

function ScanComments:scanTillNewLine(word,char)
	self:addToTable(char,word)
	return ScanTIllNewLine
end

function ScanComments:parseInput(word,char)
	if self:checkIfEndOfWordMatches(word,"-") then return self:scanTillNewLine(word,char) end
	self:addToTable(char,word)
	return ScanChars
end

return ScanComments
