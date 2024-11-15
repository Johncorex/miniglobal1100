keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

-- IDs das montarias que voc� quer dar de gra�a em cada n�vel
local mountsByLevel = {
    [100] = {7},   -- ID 7 para n�vel 100
    [400] = {8},   -- ID 8 para n�vel 400 (exemplo, altere conforme necess�rio)
    [500] = {9}    -- ID 9 para n�vel 500 (exemplo, altere conforme necess�rio)
}

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local function giveMountsForLevel(cid, level)
    local mounts = mountsByLevel[level]
    if mounts then
        local receivedAnyMount = false
        for _, mountId in ipairs(mounts) do
            if not getPlayerMount(cid, mountId) then
                doPlayerAddMount(cid, mountId)
                receivedAnyMount = true
                -- Mensagem opcional, pode ser removida se n�o for necess�ria
                doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, 'voce acaba de ganhar uma mountaria por atingir os leveis desejados ' .. level .. '.')
            end
        end
        return receivedAnyMount
    end
    return false
end

local function checkPlayerLevelForMounts(cid)
    local playerLevel = getPlayerLevel(cid)
    if playerLevel >= 500 then
        giveMountsForLevel(cid, 500)
    elseif playerLevel >= 400 then
        giveMountsForLevel(cid, 400)
    elseif playerLevel >= 100 then
        giveMountsForLevel(cid, 100)
    end
end

local function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then
        return false
    end

    if msgcontains(msg, 'mount') then
        -- Verifica o n�vel do jogador
        local playerLevel = getPlayerLevel(cid)
        if playerLevel < 100 then
            npcHandler:say('ASSIM QUE VOC� ATINGIR OS LEVEIS: LVL 100, LVL 400, LVL 500, GANHAR� AS MOUNTS Gratis.', cid)
        else
            checkPlayerLevelForMounts(cid)
            npcHandler:say('ASSIM QUE VOC� ATINGIR OS LEVEIS: LVL 100, LVL 400, LVL 500, GANHAR� GANHARA AS MOUNTS Gratis,!', cid)
        end
        npcHandler:releaseFocus(cid)
    else
        npcHandler:say('Posso lhe dar uma montaria gratuita, desde que voce atinja o nivel necessario. Apenas diga {mount}.', cid)
    end
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())