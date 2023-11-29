local ScanChars <const> = require('scanner.ScanChars')
local setmetatable <const> = setmetatable
local gmatch <const> = string.gmatch
local io = io

local Scanner <const> = {}
Scanner.__index = Scanner

_ENV = Scanner

function Scanner:scanFile()
	io.write("scanning file\n")
	local word <const> = {}
	local allWords <const> = {}
	local currentScannerMode = ScanChars
	for char in gmatch(self.file.text,".") do
		currentScannerMode = currentScannerMode:parseInput(word,char,allWords)
		io.write("\n current mode is: ",currentScannerMode.type,"\n")
	end
	ScanChars:createNewWord(word,allWords)
	return allWords
end

function Scanner:new(file)
	return setmetatable({file = file},self)
end

return Scanner
