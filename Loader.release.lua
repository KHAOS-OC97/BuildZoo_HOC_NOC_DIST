-- HOC_NOC Loader v1.0.15
-- Gerado automaticamente. Nao edite manualmente.
local __SRC = game:HttpGet("https://raw.githubusercontent.com/KHAOS-OC97/BuildZoo_HOC_NOC_DIST/main/HOC_NOC.release.obf.lua", true)
local __L = loadstring or load
assert(type(__L) == "function", "[HOC NOC] Executor sem loadstring/load")
local __F, __E = __L(__SRC)
assert(type(__F) == "function", "[HOC NOC] Compile error: " .. tostring(__E))
__F()
