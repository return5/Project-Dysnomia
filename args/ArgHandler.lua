local ArgOption <const> = require('args.ArgOptions')
local ConfigManager <const> = require('config.ConfigManager')
local Config <const> = require  ('config.config')

local write <const> = io.write
local pcall <const> = pcall
local stdError <const> = io.stderr
local exit <const> = os.exit
local pairs <const> = pairs
local concat <const> = table.concat
local popen <const> = io.popen
local getenv <const> = os.getenv

local ArgHandler <const> = {type = "ArgHandler"}
ArgHandler.__index = ArgHandler

_ENV = ArgHandler

local separators <const> = {
	linux = "/",
	windows = "\\"
}

local newLines <const> = {
	linux = "\n",
	windows = "\r\n"
}

--forward declare this var.
local argOptions

--code which attempts to grab host os type.
--found as a gist by soulik on github
local function getOSType()
	local popen_status, popen_result = pcall(popen, "")
	if popen_status then
		popen_result:close()
		-- Unix-based OS
		ConfigManager:setOs(popen('uname -s','r'):read('*l'))
	else
		-- Windows
		ConfigManager:setOs(getenv('OS'))
	end
	if Config.os == nil then
		stdError:write("Error: could not determine host Operating system. Suggestion: pass in command line argument '",argOptions.os.option,"'\n")
	end
end

local function getSep()
	--if couldnt find either then error out
	if separators[Config.os] then
		ConfigManager:setSep(separators[Config.os])
	else
		stdError:write("Error: could not find file separator for ",Config.os," Operating system. suggestion: pass in commandline argument '",argOptions.sep.option,"'\n")
		exit(64)
	end
end

local function getNewLine()
	--if couldnt find either then error out
	if separators[Config.os] then
		ConfigManager:setNewLine(newLines[Config.os])
	else
		stdError:write("Error: could not find file separator for ",Config.os," Operating system. suggestion: pass in commandline argument '",argOptions.sep.option,"'\n")
		exit(64)
	end
end

local function printHelp()
	write("Project Dysnomia. Adding functionality on top of Lua.\r\ndysnomia [options] file\r\noptions:\r\n")
	for _,v in pairs(argOptions) do
		write("\t",v.option,"\t",v.desc,"\r\n")
	end
end

local function osType(_,checkSep,checkNl,args)
	local os <const> =  args:match(argOptions.os.pat)
	ConfigManager:setOs(os)
	return nil,checkSep,checkNl
end

local function printHelpAndExit()
	printHelp()
	exit(75)
end

local function parseOnly(checkOs,checkSep,checkNl)
	ConfigManager:setRun(false)
	ConfigManager:setTemp(false)
	return checkOs,checkSep,checkNl
end

local function sepType(checkOs,_,checkNl,args)
	local sep <const> =  args:match(argOptions.sep.pat)
	ConfigManager:setSep(sep)
	return checkOs,nil,checkNl
end

local function permFiles(checkOs,checkSep,checkNl)
	ConfigManager:setTemp(false)
	return checkOs,checkSep,checkNl
end

local function tempFiles(checkOs,checkSep,checkNl)
	ConfigManager:setTemp(true)
	return checkOs,checkSep,checkNl
end

local function newLineType(checkOs,checkSep,_,args)
	ConfigManager:setSep(args:match(argOptions.newLine.pat))
	return checkOs,checkSep,nil
end


local function skipFiles(checkOs,checkSep,checkNl,args)
	local files <const> = args:match(argOptions.skip.pat)
	for match in files:gmatch("[^,]+") do
		ConfigManager:addToSkipFiles(match)
	end
	return checkOs,checkSep,checkNl
end

argOptions = {
	parse = ArgOption:new("-parse","-parse;","only parse through files, do not run the program after parsing.",parseOnly),
	os = ArgOption:new("-os [os name]","-os;?%s*([^;]+);","enter the os type you are using, such as linux or windows.",osType),
	sep = ArgOption:new("-sep [separator]","-sep;?%s*([^;]+);","the file separator used by your OS for filepaths.",sepType),
	perm = ArgOption:new("-perm","-perm;","Do not remove generated files after running.",permFiles),
	temp = ArgOption:new("-temp","-temp;","remove all generated files after running.(default)",tempFiles),
	skip = ArgOption:new("-skip [files]","-skip;?s*(.+);","comma separated list of files to skip over",skipFiles),
	help = ArgOption:new("-help","-help;","print help screen.",printHelpAndExit),
	newLine = ArgOption:new("-nl -[char(s)]","-nl:?s*(.+);","enter the newline character(s) which your OS uses.",newLineType)
}

function ArgHandler.parseOptions(arg,preChecks)
	local args <const> = concat(arg,";")
	local checkOs = getOSType
	local checkSep = getSep
	local checkNl = getNewLine
	for _,v in pairs(argOptions) do
		if args:match(v.pat) then
			checkOs,checkSep,checkNl = v.func(checkOs,checkSep,checkNl,args)
		end
	end
	preChecks[#preChecks + 1] = checkOs
	preChecks[#preChecks + 1] = checkSep
	preChecks[#preChecks + 1] = checkNl
	return
end

return ArgHandler
