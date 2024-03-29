local ScanChars <const> = require('dysnomiaScanner.ScanChars')
require('dysnomiaScanner.ScannerDriver')

local setmetatable <const> = setmetatable
local gmatch <const> = string.gmatch

local Scanner <const> = {type = "Scanner"}
Scanner.__index = Scanner

_ENV = Scanner

function Scanner:scanFile()
	local word <const> = {}
	local allWords <const> = {}
	local currentScannerMode = ScanChars
	for char in gmatch(self.file.text,".") do
		currentScannerMode = currentScannerMode:parseInput(word,char,allWords)
	end
	ScanChars:createNewWord(word,allWords)
	return allWords
end

function Scanner:new(file)
	return setmetatable({file = file},self)
end

return Scanner

