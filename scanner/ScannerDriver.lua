local ScanToEndingChar<const> = require('scanner.ScanToEndingChar')
local ScanSpaces <const> = require('scanner.ScanSpaces')
local ScanTilNext <const> = require('scanner.ScanTilNext')
local ScanMinusSign <const> = require('scanner.ScanMinusSign')
local ScanChars <const> = require('scanner.ScanChars')

local ScannerDriver <const> = {type = 'ScannerDriver'}
ScannerDriver.__index = ScannerDriver

_ENV = ScannerDriver

local scanToSingleQuote <const> = ScanToEndingChar:new("'")
local scanToDoubleQuote <const> = ScanToEndingChar:new('"')
local scanTilEqualSign <const> = ScanTilNext:new("=")
local scanMinusSign <const> = ScanMinusSign:new()

function ScannerDriver:scanSingleQuote(word,char)
	return scanToSingleQuote:openingChar(word,char)
end

function ScannerDriver:scanDoubleQuote(word,char)
	return scanToDoubleQuote:openingChar(word,char)
end

function ScannerDriver:scanSpaces(word,char,allWords)
	return ScanSpaces:scanFirstSpace(word,char,allWords)
end

function ScannerDriver:scanMathOps(word,char,allWords)
	return scanTilEqualSign:firstInput(word,char,allWords)
end

function ScannerDriver:scanMinusSign(word,char,allWords)
	return scanMinusSign:firstInput(word,char,allWords)
end

local function postConstruct()
	ScanChars.initScannerDriver(ScannerDriver)
end

postConstruct()

return ScannerDriver
