local ScanEqualSign <const> = require('scanner.ScanEqualSign')
local ScanToEndingChar<const> = require('scanner.ScanToEndingChar')
local ScanSpaces <const> = require('scanner.ScanSpaces')

local ScannerDriver <const> = {type = 'ScannerDriver'}
ScannerDriver.__index = ScannerDriver

_ENV = ScannerDriver

local scanToSingleQuote <const> = ScanToEndingChar:new("'")
local scanToDoubleQuote <const> = ScanToEndingChar:new('"')

function ScannerDriver:scanEqualSign(word,char,allWords)
	return ScanEqualSign:parseInput(word,char,allWords)
end

function ScannerDriver:scanSingleQuote(word,char)
	return scanToSingleQuote:openingQuote(word,char)
end

function ScannerDriver:scanDoubleQuote(word,char)
	return scanToDoubleQuote:openingQuote(word,char)
end

function ScannerDriver:scanSpaces(word,char,allWords)
	return ScanSpaces:scanFirstSpace(word,char,allWords)
end

return ScannerDriver
