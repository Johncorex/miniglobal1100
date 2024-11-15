function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local storageTimeexp = 23321  -- storage
    local cooldownTime = 12 * 60 * 60  -- 12 horas
    local lastUseTime = player:getStorageValue(storageTimeexp)

    if lastUseTime > 0 and os.time() - lastUseTime < cooldownTime then
        player:sendTextMessage(MESSAGE_INFO_DESCR, "[ARENAOT] Você só pode usar este item novamente a cada 12 horas.")
        return true
    end

    local currentLevel = player:getLevel()
    local minLevelGain, maxLevelGain
    
	-- se o jogador for lvl < 150 ele ganha entre 1 a 10 leveis
    if currentLevel <= 150 then
        minLevelGain = 1
        maxLevelGain = 10
    else
	-- se o jogador for level 151 > ele recebe apenas 1 a 2 level
        minLevelGain = 1
        maxLevelGain = 2
    end
    
	-- randomizar o ganho de level/exp
    local levelGain = math.random(minLevelGain, maxLevelGain)
    local newLevel = currentLevel + levelGain
    local experienceToAdd = 0

    -- calcular a experiência necessária para um determinado nível
    local function getExperienceForLevel(level)
        return math.floor((50 * (level - 1) * (level - 1) * (level - 1) - 150 * (level - 1) * (level - 1) + 400 * (level - 1)) / 3)
    end

    for level = currentLevel + 1, newLevel do
        experienceToAdd = experienceToAdd + getExperienceForLevel(level) - getExperienceForLevel(level - 1)
    end

    player:addExperience(experienceToAdd)
    player:sendTextMessage(MESSAGE_INFO_DESCR, "[ARENAOT] Parabéns, você ganhou " .. levelGain .. " níveis!")

    -- Remover o item após o uso
    item:remove(1)

    -- Atualizar o tempo de uso no storage
    player:setStorageValue(storageTimeexp, os.time())

    return true
end
