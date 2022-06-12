-- Instalator -
-- Bazowany na https://github.com/ShicKla/AuspexGateSystems/blob/release/ags/AuspexGateSystems.lua
local component = require("component")
local shell = require("shell")
local tty = require("tty")
local internet = nil
local HasInternet = component.isAvailable("internet")
local BranchURL = "https://raw.githubusercontent.com/lukasz4444/Program-Wybierajacy/main/polska-wersja/"

if HasInternet then internet = require("internet") end

local function forceExit(code)
    if UsersWorkingDir ~= nil then shell.setWorkingDirectory(UsersWorkingDir) end
    tty.setViewport(table.unpack(OriginalViewport))
    os.exit(code)
end

local function downloadFile(fileName, verbose)
    if verbose then print("Pobieranie..."..fileName) end
    local result = ""
    local response = internet.request(BranchURL..fileName)
    local isGood, err = pcall(function()
        local file, err = io.open(fileName, "w")
        if file == nil then error(err) end
        for chunk in response do
            file:write(chunk)
        end
        file:close()
    end)
    if not isGood then
        io.stderr:write("Nie można pobrać pliku")
        io.stderr:write(err)
        forceExit(false)
    end
end
downloadFile("off.lua",true)
downloadFile("wybierz.lua",true)
downloadFile("adresy.csv",true)