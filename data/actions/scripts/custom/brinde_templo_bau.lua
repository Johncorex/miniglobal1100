function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local crystalCoinId = 2160
    local amount = 5
    local storageKey = 12999 -- Escolha um ID �nico para a storage

    if player:getStorageValue(storageKey) ~= 1 then
        if player:addItem(crystalCoinId, amount) then
            player:setStorageValue(storageKey, 1)
            player:sendTextMessage(MESSAGE_INFO_DESCR, "Voc� recebeu 5 crystal coins!")
            return true
        else
            player:sendTextMessage(MESSAGE_STATUS_WARNING, "Voc� n�o tem espa�o suficiente para receber as moedas.")
            return false
        end
    else
        player:sendTextMessage(MESSAGE_STATUS_WARNING, "Voc� j� pegou essa recompensa.")
        return false
    end
end
