local OPCODE_LANGUAGE = 1
function tableToString(tb) -- by Mock
        if type(tb) ~= "table" then
                return nil, error("bad argument #1 to 'saveTable' (table expected, got "..type(tb)..")", 2)
        end
        local str = "{"
        for k,d in pairs(tb) do
                if type(k) == 'string' then
                        if type(d) == 'string' then
                                str = str..""..k.."='"..d.."',"
                        elseif type(d) == 'number' or type(d) == 'boolean' then
                                str = str..""..k.."="..tostring(d)..","
                        elseif type(d) == 'table' then
                                str = str..'{'
                                for e,f in pairs(d) do
                                        if type(e) == 'string' then
                                                if type(f) == 'string' then
                                                        str = str..""..e.."='"..f.."',"
                                                elseif type(f) == 'number' or type(e) == 'boolean' then
                                                        str = str..""..e.."="..tostring(f)..","
                                                elseif type(f) == 'table' then
                                                        str = str..""..e.."="..tableToString(f)..","
                                                end
                                        elseif type(e) == 'number' then
                                                if type(f) == 'string' then
                                                        str = str.."["..e.."]='"..f.."',"
                                                elseif type(f) == 'number' or type(f) == 'boolean' then
                                                        str = str.."["..e.."]="..tostring(f)..","
                                                elseif type(f) == 'table' then
                                                        str = str.."["..e.."]="..tableToString(f)..","
                                                end
                                        end
                                end
                                str = str..'},'
                        end
                elseif type(k) == 'number' then
                        if type(d) == 'string' then
                                str = str.."["..k.."]='"..d.."',"
                        elseif type(d) == 'number' or type(d) == 'boolean' then
                                str = str.."["..k.."]="..tostring(d)..","
                        elseif type(d) == 'table' then
                                str = str..'{'
                                for e,f in pairs(d) do
                                        if type(e) == 'string' then
                                                if type(f) == 'string' then
                                                        str = str..""..e.."='"..f.."',"
                                                elseif type(f) == 'number' or type(e) == 'boolean' then
                                                        str = str..""..e.."="..tostring(f)..","
                                                elseif type(f) == 'table' then
                                                        str = str..""..e.."="..tableToString(f)..","
                                                end
                                        elseif type(e) == 'number' then
                                                if type(f) == 'string' then
                                                        str = str.."["..e.."]='"..f.."',"
                                                elseif type(f) == 'number' or type(f) == 'boolean' then
                                                        str = str.."["..e.."]="..tostring(f)..","
                                                elseif type(f) == 'table' then
                                                        str = str.."["..e.."]="..tableToString(f)..","
                                                end
                                        end
                                end
                                str = str..'},'
                        end
                end
        end
        local str = str.."}"
        if string.sub(str,string.len(str)-2,string.len(str)-2) == "," then
                str = string.sub(str,0,string.len(str)-3).."}"
        end
        return str
end

function sendPackageToClient(self, opcode, buffer)
  
  
  local networkMessage = NetworkMessage()
  networkMessage:addByte(0x32)
  networkMessage:addByte(opcode)
  networkMessage:addString(tableToString(buffer))
  networkMessage:sendToPlayer(self)
  networkMessage:delete()
  return true
end



dofile('data/lib/core/json.lua')
local json = require('data/lib/core/json')

--dofile('data/creaturescripts/scripts/opcodes/example.lua')

local OPCODE_LANGUAGE = 1

        -- Deklaracja pakietu
        local OPCODE = {
                EXAMPLE = 16,
          }

function onExtendedOpcode(player, opcode, buffer)
    
  if opcode == OPCODE.EXAMPLE then
    return onExampleOpcode(player, buffer)    
  end
  
        if opcode == OPCODE_LANGUAGE then
                -- otclient language
                if buffer == 'en' or buffer == 'pt' then
                        -- example, setting player language, because otclient is multi-language...
                        -- player:setStorageValue(SOME_STORAGE_ID, SOME_VALUE)
                end
        elseif opcode == 23 then
               player:sendExtendedOpcode(EAT_OPCODE, tostring(storageValue))
        elseif opcode == 215 then
               TaskSystem.onAction(player, json.decode(buffer))
        else
                -- other opcodes can be ignored, and the server will just work fine...
        end

end