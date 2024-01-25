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
local Parser <const> = require('parser.Parser')
local Scanner <const> = require('scanner.Scanner')
local FileSkipper <const> = require('fileOperations.FileSkipper')
local ArgHandler <const> = require('misc.ArgHandler')


local function runParser()
	local fileReader <const> = FileReader:new(FileReader.checkMainFile(arg[#arg]))
	local file <const> = fileReader:readFile()
	local isSkipped <const> = FileSkipper:scanForSkipFile(file)
	if file and not isSkipped then
		local scanned <const> = Scanner:new(file):scanFile()
		local parser <const> = Parser:new(scanned,file.filePath)
		if file.isLuaFile then
			parser:parseLuaFile()
		else
			parser:beginParsing()
		end
		if Config.run then
			local file <const> = arg[#arg]:gsub("%.dys$",".lua")
			os.execute("lua " .. file)
		end
		if Config.temp then
			FileWriter.removeFiles()
		end
	end
end

local function main()
	if #arg == 0 then
		printHelp()
		os.exit(75)
	end
	local preChecks <const> = {}
	if #arg > 0 then
		ArgHandler.parseOptions(arg,preChecks)
	end
	for i=1,#preChecks,1 do
		preChecks[i]()
	end
	runParser()
end

main()
