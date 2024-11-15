function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    print("Item usado: " .. item:getId())
    if target and target:isItem() then
        print("Alvo é um item.")
        local itemType = target:getType()
        if itemType and not itemType:isMovable() then
            print("Alvo é uma porta de casa.")
            local houseDoorId = target:getAttribute(ITEM_ATTRIBUTE_HOUSEDOORID)
            if not houseDoorId then
                player:sendCancelMessage("Esta porta não pertence a uma casa.")
                return true
            end

            print("ID da porta da casa: " .. houseDoorId)
            local house = House(houseDoorId)
            if not house then
                player:sendCancelMessage("Esta casa não existe.")
                return true
            end

            print("Casa encontrada: " .. house:getName())
            if house:getOwnerGuid() ~= 0 then
                player:sendCancelMessage("Esta casa já tem um dono.")
                return true
            end

            if not player:removeItem(2090, 1) then
                player:sendCancelMessage("Você precisa do item com ID 2090 para comprar esta casa.")
                return true
            end

            house:setOwnerGuid(player:getGuid())
            player:sendTextMessage(MESSAGE_INFO_DESCR, "Você comprou a casa " .. house:getName() .. ".")
            return true
        else
            print("Alvo não é uma porta de casa.")
        end
    else
        print("Alvo não é um item.")
    end

    player:sendCancelMessage("Você precisa usar este item em uma porta de casa.")
    return true
end
