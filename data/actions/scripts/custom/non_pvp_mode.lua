local nonPvpStorage = 54661  -- Defina um valor de armazenamento �nico para o modo NON PVP
local nonPvpDuration = 5 * 60 * 60  -- 5 horas em segundos

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local currentTime = os.time()
    local nonPvpEndTime = player:getStorageValue(nonPvpStorage)

    if nonPvpEndTime > currentTime then
        player:sendCancelMessage("[ATEN��O] Voc� j� est� no modo NON PVP.")
        return true
    end

    -- Ativar modo NON PVP
    player:setStorageValue(nonPvpStorage, currentTime + nonPvpDuration)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "[ATEN��O] O jogador alterou seu PVP Type para NON PVP.")

    -- Mensagem para todos os jogadores online
    local message = "[ATEN��O] o jogador " .. player:getName() .. " comprou na Store o item PVP Type Z e ativou o modo NON PVP por 5 horas."
    for _, onlinePlayer in ipairs(Game.getPlayers()) do
        onlinePlayer:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
    end

    -- Remover o item do invent�rio do jogador
    player:removeItem(item:getId(), 1)

    return true
end