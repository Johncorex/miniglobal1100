local gifts = {
    {id = 2160, name = "Crystal Coin"},
    {id = 2152, name = "Platinum Coin"},
    {id = 2148, name = "Gold Coin"},
    {id = 2165, name = "Ring of Healing"},
    {id = 2173, name = "Amulet of Loss"}
}

local storage = 12824 -- Storage ID para controlar o tempo de cooldown
local cooldown = 15 * 60 * 60 -- 15 horas em segundos

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local lastGiftTime = player:getStorageValue(storage)
    if lastGiftTime > os.time() then
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "Você só pode escolher um brinde a cada 15 horas.")
        return true
    end

    local modalWindow = ModalWindow(1000, "Escolha seu brinde", "Selecione um dos itens abaixo:")
    for i, gift in ipairs(gifts) do
        modalWindow:addChoice(i, gift.name)
    end

    modalWindow:addButton(100, "Confirmar")
    modalWindow:addButton(101, "Fechar")
    modalWindow:setDefaultEnterButton(100)
    modalWindow:setDefaultEscapeButton(101)
    modalWindow:sendToPlayer(player)

    player:registerEvent("GiftModal")
    return true
end
