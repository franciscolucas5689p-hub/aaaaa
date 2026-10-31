-- loader.lua
-- Substitua SEU_USUARIO e o caminho pelo endereco RAW do arquivo publicado.
local url = "https://raw.githubusercontent.com/SEU_USUARIO/ORELHA_HUB/main/ORELHA_HUB.lua"
local source = game:HttpGet(url)
local fn, err = loadstring(source)
if not fn then error(err) end
fn()
