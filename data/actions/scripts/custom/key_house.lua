function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    print("Item usado: " .. item:getId())
    if target and target:isItem() then
        print("Alvo � um item.")
        local itemType = target:getType()
        if itemType and not itemType:isMovable() then
            print("Alvo � uma porta de casa.")
            local houseDoorId = target:getAttribute(ITEM_ATTRIBUTE_HOUSEDOORID)
            if not houseDoorId then
                player:sendCancelMessage("Esta porta n�o pertence a uma casa.")
                return true
            end

            print("ID da porta da casa: " .. houseDoorId)
            local house = House(houseDoorId)
            if not house then
                player:sendCancelMessage("Esta casa n�o existe.")
                return true
            end

            print("Casa encontrada: " .. house:getName())
            if house:getOwnerGuid() ~= 0 then
                player:sendCancelMessage("Esta casa j� tem um dono.")
                return true
            end

            if not player:removeItem(2090, 1) then
                player:sendCancelMessage("Voc� precisa do item com ID 2090 para comprar esta casa.")
                return true
            end

            house:setOwnerGuid(player:getGuid())
            player:sendTextMessage(MESSAGE_INFO_DESCR, "Voc� comprou a casa " .. house:getName() .. ".")
            return true
        else
            print("Alvo n�o � uma porta de casa.")
        end
    else
        print("Alvo n�o � um item.")
    end

    player:sendCancelMessage("Voc� precisa usar este item em uma porta de casa.")
    return true
end
