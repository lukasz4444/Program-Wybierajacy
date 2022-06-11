c = require("component")
event = require("event")
os = require("os")
sg = c.stargate
term = require("term")

address = {}

glyphs = {
	"Andromeda",
	"Aquarius",
	"Aquila",	-- Ten symbol nie istnieje w modzie jest tu tylko dla organizacji.
	"Aries",
	"Auriga",
	"Bootes",
	"Cancer",
	"Canis Minor",
	"Capricornus",
	"Centaurus",
	"Cetus",
	"Corona Australis",
	"Crater",
	"Equuleus",
	"Eridanus",
	"Gemini",
	"Hydra",
	"Leo Minor",
	"Leo",
	"Libra",
	"Lynx",
	"Microscopium",
	"Monoceros",
	"Norma",
	"Orion",
	"Pegasus",
	"Perseus",
	"Pisces",
	"Piscis Austrinus",
	"Sagittarius",
	"Scorpius",
	"Sculptor",
	"Scutum",
	"Serpens Caput",
	"Sextans",
	"Taurus",
	"Triangulum",
	"Virgo"
}

-- Funkcja Wprowadzania Ręcznego
term.clear()
function manualDial()
	print("Lista Symboli: ")
	for i, v in ipairs(glyphs) do
		if i < 20 then
			-- formatting mostly
			if (i > 2 and i < 8) or i == 11 or i == 13 or i == 16 or i == 17 or i == 19 then
				print(i, v, "\t\t" .. i + 19, glyphs[i + 19])
			elseif i == 12 then print(i, v, i + 19, glyphs[i + 19])
			else print(i, v, "\t" .. i + 19, glyphs[i + 19]) end
		else break end
	end
	print("Wprowadź adres w liczbach oddzielonych przecinkami lub 'q' , aby przerwać.")
	print()

	raw_address = io.read()
	if raw_address == "q" then os.exit() end

	address = {}
	for num in string.gmatch(raw_address, '([^,]+)') do -- regex to convert a comma separated list to a table
		table.insert(address, glyphs[tonumber(num)])
	end

	print("Is this address correct? (y/n)")
	for i, v in ipairs(address) do print(i, v) end
	choice = io.read()
	if choice ~= "y" then os.exit() end
end
term.clear()
-- reading from the saved addresses file and loading it
saved_addresses = {}
lines = {}
file = "adresy.csv"

for line in io.lines(file) do lines[#lines + 1] = line end
for i = 1, #lines do
	local t = {}
	for w in lines[i]:gmatch("([^,]+),?") do table.insert(t, w) end
	table.insert(saved_addresses, t)
end
-- main program area
print("Do jakich wrót chcesz otworzyć tunel? (WPROWADZAJ TYLKO LICZBY!)")
print("0. Manualne Wprowadzanie")
-- print all saved addresses and let user choose
for i = 1, #saved_addresses do print(i .. ". " .. saved_addresses[i][1]) end

choice = io.read()
if choice == "0" then manualDial()
elseif tonumber(choice) ~= nil then
	index = tonumber(choice)
	if (saved_addresses[index] ~= nil) or (saved_addresses[index] ~= {}) then
		for i = 2, #(saved_addresses[index]) do
			table.insert(address, saved_addresses[index][i])
		end
	else
		print("Niewłaściwy wybór.")
		os.exit()
	end
else
	print("Niewłaściwy wybór.")
	os.exit()
end

-- Punkt początkowy jest automatycznie dodawany na końcu każdego adresu, więc nie ma potrzeby dodawania go do adresy.csv
table.insert(address, "Point of Origin")

term.clear()
-- Otwieranie wrót.
print("Wybieranie")
for i, v in ipairs(address) do print(i, v) end
print()

loop = true
term.clear()
function dialNext(dialed)
	glyph = address[dialed + 1]
	sg.engageSymbol(glyph)
end

function cancelEvents()
	event.cancel(eventEngaged)
	event.cancel(openEvent)
	event.cancel(failEvent)

	loop = false
end

eventEngaged = event.listen("stargate_spin_chevron_engaged", function(evname, address, caller, num, lock, glyph)

	if lock then
		print("Szewron " .. num .. " Zablokowany")
		os.sleep(0.5)
		sg.engageGate()
	else
		print("Szewron " .. num .. " Wprowadzony -", glyph)
		os.sleep(0.5)
		dialNext(num)
	end
end)

dialNext(0)

openEvent = event.listen("stargate_open", function()
	cancelEvents()
end)

failEvent = event.listen("stargate_failed", function(address, caller, reason)
	print("Szewron z punktem początkowym się nie wprowadza.")
	cancelEvents()
end)

while loop do os.sleep(0.1) end

