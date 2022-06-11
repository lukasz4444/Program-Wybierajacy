os = require("os")
c = require("component")
sg = c.stargate
sg.abortDialing()
local g,d = sg.disengageGate()

if d == "stargate_failure_wrong_end" then
    print("Nie można wyłączyć przychodzącego tunelu")
elseif d == "stargate_failure_not_open" then
    print("Wrota nie są otwarte.")
end