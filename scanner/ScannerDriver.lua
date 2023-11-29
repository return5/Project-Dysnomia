local ScanEqualSign <const> = require('scanner.ScanEqualSign')
local ScanToEndingChar<const> = require('scanner.ScanToEndingChar')

local ScannerDriver <const> = {type = 'ScannerDriver'}
ScannerDriver.__index = ScannerDriver

_ENV = ScannerDriver

local scanToSingleQuote <const> = ScanToEndingChar:new("'")
local scanToDoubleQuote <const> = ScanToEndingChar:new('"')

function ScannerDriver:handleEqualSign(word,char,allWords)
	return ScanEqualSign:parseInput(word,char,allWords)
end

function ScannerDriver:handleSingleQuote()
	return scanToSingleQuote
end

function ScannerDriver:handleDoubleQuote()
	return scanToDoubleQuote
end

return ScannerDriver
