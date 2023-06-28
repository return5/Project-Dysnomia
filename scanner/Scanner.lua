
local setmetatable <const> = setmetatable
local concat <const> = table.concat
local gmatch <const> = string.gmatch


local Scanner <const> = {}
Scanner.__index = Scanner

_ENV = Scanner


local function createWord(word,tbl)
	if #word > 0 then
		tbl[#tbl + 1] = concat(word)
		--TODO test if faster to blank word
		return {}
	end
	return word
end

local function handleWordBreak(word,tbl,char)
	local newWord <const> = createWord(word,tbl)
	tbl[#tbl + 1] = char
	return newWord
end

local function breakWordThenAddNewChar(word,tbl,char)
	local newWord <const> = createWord(word,tbl)
	newWord[#newWord + 1] = char
	return newWord
end

local function loopSpaces(word,tbl,char,flags)
	local newWord <const> = breakWordThenAddNewChar(word,tbl,char)
	flags.loopSpaces = true
	flags.skipChecks = true
	return newWord
end

local function endLoopSpaces(word,tbl,flags,char)
	flags.loopSpaces = false
	flags.skipChecks = false
	return breakWordThenAddNewChar(word,tbl,char)
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
	return breakWordThenAddNewChar(word,tbl,char)
end

local wordBreaks <const> = {
	[","] = handleWordBreak,
	[")"] = handleWordBreak,
	["("] = handleWordBreak,
	[";"] = handleWordBreak,
	["\n"] = handleWordBreak,
	["-"] = breakWordThenAddNewChar
}

local spaceTbl <const> = {
	[" "] = loopSpaces,
	["\t"] = loopSpaces,
}

local quoteTable <const> = {
	["'"] = true,
	['"'] = true
}


function Scanner.scanFile(file)
	local tbl <const> = {}
	local word = {}
	local prevChar = ""
	local flags <const> = { loopSpaces = false, skipChecks = false, skipToClosing = false}
	local closingChar = ""
	for char in gmatch(file,".") do
		if flags.skipToClosing then
			if char == closingChar and prevChar ~= "\\" then
				word = endSkipToChar(word,tbl,flags,char)
				closingChar = ""
			else
				word[#word + 1] = char
			end
		elseif flags.loopSpaces then
			if spaceTbl[char] then
				word[#word + 1] = char
			else
				word = endLoopSpaces(word,tbl,flags,char)
			end
		end
		if not flags.skipChecks then
			if quoteTable[char] then
				closingChar = skipChars(word,char,flags)
			elseif char == "-" and prevChar == "-" then
				skipChars(word,char,flags)
				closingChar = "\n"
			elseif wordBreaks[char]	then
				word = wordBreaks[char](word,tbl,char,flags)
			elseif spaceTbl[char] then
				word = spaceTbl[char](word,tbl,char,flags)
			else
				word[#word + 1] = char
			end
		end
		prevChar = char
	end
	createWord(word,tbl)
	return tbl
end

function Scanner:new()
	return setmetatable({},self)
end

return Scanner
