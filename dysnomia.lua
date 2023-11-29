--[[
	dysnomia: a programing language running on top of lua 5.4 . extends syntax and features of lua 5.4
    Copyright (C) <2023>  <return5>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

local Config <const> = require  ('config.config')
local FileReader <const> = require  ('fileOperations.FileReader')
local FileWriter <const> = require  ('fileOperations.FileWriter')
local ArgOption <const> = require('misc.ArgOptions')
local Parser <const> = require('parser.Parser')
local Scanner <const> = require('scanner.Scanner')
local ScannerDriver <const> = require('scanner.ScannerDriver')
local ScanChars <const> = require('scanner.ScanChars')

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
--found as a gist by: soulik on github
local function getOSType()
	local popen_status, popen_result = pcall(io.popen, "")
	if popen_status then
		popen_result:close()
		-- Unix-based OS
		Config.os = string.lower(io.popen('uname -s','r'):read('*l'))
	else
		-- Windows
		Config.os = string.lower(os.getenv('OS'))
	end
	if Config.os == nil then
		io.stderr:write("Error: could not determine host Operating system. Suggestion: pass in command line argument '",argOptions.os.option,"'\n")
	end
end

local function getSep()
	--if couldnt find either then error out
	if separators[Config.os] then
		Config.sep = separators[Config.os]
	else
		io.stderr:write("Error: could not find file separator for ",Config.os," Operating system. suggestion: pass in commandline argument '",argOptions.sep.option,"'\n")
		os.exit(64)
	end
end

local function getNewLine()
	--if couldnt find either then error out
	if separators[Config.os] then
		Config.newLine = newLines[Config.os]
	else
		io.stderr:write("Error: could not find file separator for ",Config.os," Operating system. suggestion: pass in commandline argument '",argOptions.sep.option,"'\n")
		os.exit(64)
	end
end

local function printHelp()
	io.write("Project Dysnomia. Adding functionality on top of Lua.\r\ndysnomia [options] file\r\noptions:\r\n")
	for _,v in pairs(argOptions) do
		io.write("\t",v.option,"\t",v.desc,"\r\n")
	end
end

local function osType(_,checkSep,checkNl,args)
	local os <const> =  args:match(argOptions.os.pat)
	Config.os = os:lower()
	return nil,checkSep,checkNl
end

local function printHelpAndExit()
	printHelp()
	os.exit(75)
end

local function parseOnly(checkOs,checkSep,checkNl)
	Config.run = false
	Config.temp = false
	return checkOs,checkSep,checkNl
end

local function sepType(checkOs,_,checkNl,args)
	local sep <const> =  args:match(argOptions.sep.pat)
	Config.sep = sep
	return checkOs,nil,checkNl
end

local function permFiles(checkOs,checkSep,checkNl)
	Config.temp = false
	return checkOs,checkSep,checkNl
end

local function tempFiles(checkOs,checkSep,checkNl)
	Config.temp = true
	return checkOs,checkSep,checkNl
end

local function newLineType(checkOs,checkSep,_,args)
	Config.sep = args:match(argOptions.newLine.pat)
	return checkOs,checkSep,nil
end


local function skipFiles(checkOs,checkSep,checkNl,args)
	local files <const> = args:match(argOptions.skip.pat)
	for match in files:gmatch("[^,]+") do
		Config.skip[match] = true
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

local function runParser()
	io.write("running parser\n")
	local fileReader <const> = FileReader:new(FileReader.checkMainFile(arg[#arg]))
	local file <const> = fileReader:readFile()
	if file then
		local scanned <const> = Scanner:new(file):scanFile()
		Parser:new(scanned,file.filePath):beginParsing()
		if Config.run then
			local file <const> = arg[#arg]:gsub("%.dys$",".lua")
			os.execute("lua " .. file)
		end
		if Config.temp then
			FileWriter.removeFiles()
		end
	end
end

local function parseOptions(preChecks)
	local args <const> = table.concat(arg,";")
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

local function main()
	if #arg == 0 then
		printHelp()
		os.exit(75)
	end
	local preChecks <const> = {}
	if #arg > 0 then
		parseOptions(preChecks)
	end
	for i=1,#preChecks,1 do
		preChecks[i]()
	end
	ScanChars.initScannerDriver(ScannerDriver)
	runParser()
end

main()
