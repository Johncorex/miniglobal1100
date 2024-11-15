local config = {
    levelRequirement = 90, -- Nível necessário para receber o item
    items = {
        ["elder druid"] = {id = 1841, name = "Muck Rod"}, -- muck rod
        ["master sorcerer"] = {id = 18409, name = "Wand of Everblazing"}, -- Wand of Everblazing
        ["royal paladin"] = {id = 22419, name = "Crude Umbral Crossbow"}, -- Crude Umbral Crossbow
        ["elite knight"] = {id = 12649, name = "Blade of Corruption"}, -- blade of corruption
    }
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if player:getLevel() < config.levelRequirement then
        player:sendTextMessage(MESSAGE_STATUS_WARNING, "Voce precisa estar no nivel " .. config.levelRequirement .. " ou superior para receber o item.")
        return true
    end

    local vocationName = player:getVocation():getName():lower()

    if not config.items[vocationName] then
        player:sendTextMessage(MESSAGE_STATUS_WARNING, "Voce precisa ser promotion para receber o item.")
        return true
    end

    local itemConfig = config.items[vocationName]
    local itemId = itemConfig.id
    local itemName = itemConfig.name

    if player:getItemCount(itemId) > 0 then
        player:sendTextMessage(MESSAGE_STATUS_WARNING, "Voce ja recebeu o item.")
        return true
    end

    player:addItem(itemId, 1)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "Voce recebeu o seu item: " .. itemName .. "!")
    return true
end
