
local setmetatable <const> = setmetatable
local concat <const> = table.concat
local gmatch <const> = string.gmatch

local Scanner <const> = {}
Scanner.__index = Scanner

_ENV = Scanner


local function clearWord(word)
	for i=#word,1,-1 do
		word[i] = nil
	end
end

local function createWord(word,tbl)
	if #word > 0 then
		tbl[#tbl + 1] = concat(word)
		clearWord(word)
	end
end

local function handleWordBreak(word,tbl,char)
	createWord(word,tbl)
	tbl[#tbl + 1] = char
end

local function breakWordThenAddNewChar(word,tbl,char)
	createWord(word,tbl)
	word[#word + 1] = char
end

local function loopSpaces(word,tbl,char,flags)
	breakWordThenAddNewChar(word,tbl,char)
	flags.loopSpaces = true
	flags.skipChecks = true
end

local function endLoopSpaces(word,tbl,flags)
	flags.loopSpaces = false
	flags.skipChecks = false
	createWord(word,tbl)
end

local function skipChars(word,char,flags)
	flags.skipToClosing = true
	flags.skipChecks = true
	word[#word + 1] = char
	return char
end

local function endSkipToChar(word,tbl,flags,char)
	flags.skipToClosing = false
	flags.skipChecks = false
	createWord(word,tbl)
end

local mathOps <const> = {
	["+"] = true,
	["-"] = true,
	["/"] = true,
	["*"] = true
}

local function handleEquals(word,tbl,char)
	if not mathOps[word[#word]] then createWord(word,tbl) end
	word[#word + 1] = char
	createWord(word,tbl)
end

local wordBreaks <const> = {
	[","] = handleWordBreak,
	[")"] = handleWordBreak,
	["("] = handleWordBreak,
	[";"] = handleWordBreak,
	["<"] = handleWordBreak,
	[">"] = handleWordBreak,
	["="] = handleEquals,
	["\n"] = handleWordBreak,
	["-"] = breakWordThenAddNewChar,
	["+"] = breakWordThenAddNewChar,
	["/"] = breakWordThenAddNewChar,
	["*"] = breakWordThenAddNewChar
}

local spaceTbl <const> = {
	[" "] = loopSpaces,
	["\t"] = loopSpaces,
}

local quoteTable <const> = {
	["'"] = true,
	['"'] = true
}


local function handleSpaces(word,tbl,flags,char)
	--if we are on a space char then add it to word table.
	if spaceTbl[char] then
		word[#word + 1] = char
	else
		--otherwise add current word to tbl then clear word table
		endLoopSpaces(word,tbl,flags)
	end
end

local function skipToClosing(word,tbl,flags,char,prevChar,closingChar,twoPrevChar)
	--if we reach the closing char and it isnt preceded by a '\' then we can end.
	if char == closingChar and (prevChar ~= "\\" or twoPrevChar == "\\") then
		if char == "\n" then
			endSkipToChar(word,tbl,flags,char)
			word[#word + 1] = char
			createWord(word,tbl)

		else
			word[#word + 1] = char
			endSkipToChar(word,tbl,flags,char)
		end
		return ""
	end
	word[#word + 1] = char
	return closingChar
end

local function scannerChecks(word,tbl,flags,char,prevChar,closingChar)
	if quoteTable[char] then
		return skipChars(word,char,flags)
	elseif char == "-" and prevChar == "-" then
		skipChars(word,char,flags)
		return "\n"
	elseif wordBreaks[char]	then
		wordBreaks[char](word,tbl,char,flags)
	elseif spaceTbl[char] then
		spaceTbl[char](word,tbl,char,flags)
	else
		word[#word + 1] = char
	end
	return closingChar
end

function Scanner:scanFile()
	local tbl <const> = {}
	local word <const> = {}
	local prevChar = ""
	local twoPrevChar = ""
	local flags <const> = { loopSpaces = false, skipChecks = false, skipToClosing = false}
	local closingChar = ""
	for char in gmatch(self.file.text,".") do
		--loop over spaces until you get to something not a space
		if flags.loopSpaces then
			handleSpaces(word,tbl,flags,char)
		end
		--loop over chars until you get to the closing char.
		if flags.skipToClosing then
			closingChar = skipToClosing(word,tbl,flags,char,prevChar,closingChar,twoPrevChar)
		elseif not flags.skipChecks then
			closingChar = scannerChecks(word,tbl,flags,char,prevChar,closingChar)
		end
		twoPrevChar = prevChar
		prevChar = char
	end
	createWord(word,tbl)
	return tbl
end

function Scanner:new(file)
	return setmetatable({file = file},self)
end

return Scanner
