 --[[
    Script: Roleta Premiada
    Author: [jhoncore]
    Version: 2.0
    Description: Um sistema de roleta onde os jogadores podem girar e ganhar prêmios aleatórios.
    Credits: Este script foi Modificado por [Lostwalker]. 
--]]


local decayItems = {
    [1945] = 1946,
    [1946] = 1945
}

local slots = {
    Position(4365, 4028, 7),
    Position(4366, 4028, 7),
    Position(4367, 4028, 7),
    Position(4368, 4028, 7),
    Position(4369, 4028, 7),
    Position(4370, 4028, 7),
    Position(4371, 4028, 7)
}

local itemtable = {
    [1] = {id = 7405, chance = 41}, -- havoc blade
    [2] = {id = 18465, chance = 63}, -- shiny blade
    [3] = {id = 2494, chance = 21}, -- demon armor
    [4] = {id = 43002, chance = 10}, -- green demon helmet
    [5] = {id = 43001, chance = 15}, -- green demon armor
    [6] = {id = 2470, chance = 13}, -- green demon legs
    [7] = {id = 2646, chance = 38}, -- golden boots
    [8] = {id = 11393, chance = 51}, -- lucky amulet
    [9] = {id = 2493, chance = 15}, -- demon helmet
    [10] = {id = 11393, chance = 60}, -- lucky amulet
    [11] = {id = 33219, chance = 30}, -- falcon wand
    [12] = {id = 7405, chance = 1}, -- havoc blade
    [13] = {id = 18465, chance = 63}, -- shiny blade
    [14] = {id = 2494, chance = 29}, -- demon armor
    [15] = {id = 43002, chance = 10}, -- green demon helmet
    [16] = {id = 43001, chance = 17}, -- green demon armor
    [17] = {id = 7404, chance = 32}, -- assassin dagger
    [18] = {id = 12649, chance = 34}, -- blade of corruption
    [19] = {id = 25416, chance = 52}, -- Impaler of the igniter
    [20] = {id = 25416, chance = 19}, -- Bonebreaker
    [21] = {id = 7415, chance = 60}, -- cranial basher
    [22] = {id = 7431, chance = 35}, -- Demonbone
    [23] = {id = 35107, chance = 28}, -- Cobra Crossbow
    [24] = {id = 31720, chance = 53}, -- Strawberry Cupcake
    [25] = {id = 8851, chance = 18}, -- Royal Crossbow
    [26] = {id = 42062, chance = 27}, -- Gilded Eldritch Wand
    [27] = {id = 42068, chance = 18} -- Gilded Eldritch Rod
}

local function ender(cid, position)
    local player = Player(cid)
    local posicaofim = Position(4368, 4028, 7)
    local item = Tile(posicaofim):getTopDownItem()
    if item then
        local itemId = item:getId()
        posicaofim:sendMagicEffect(CONST_ME_TUTORIALARROW)
        if player then
            player:addItem(itemId, 1)
        end
    end
    local alavanca = Tile(position):getTopDownItem()
    if alavanca then
        alavanca:setActionId(18563)
    end
    if itemId == 33219 then -- checar se é o ID do item LENDARIO
        broadcastMessage("O player "..player:getName().." ganhou "..item:getName().."", MESSAGE_EVENT_ADVANCE)
        for _, pid in ipairs(getPlayersOnline()) do
            if pid ~= cid then
                pid:say("O player "..player:getName().." ganhou "..item:getName().."", TALKTYPE_MONSTER_SAY)
            end
        end
    end
end

local function delay(position, aux)
    local item = Tile(position):getTopDownItem()
    if item then
        local slot = aux + 1
        item:moveTo(slots[slot])
    end
end

local function exec(cid)
    -- calcular uma chance e atribuir um item
    local rand = math.random(1, 100)
    local aux, memo = 0, 0
    if rand >= 1 then
        for i = 1, #itemtable do
            local randitemid = itemtable[i].id
            local randitemchance = itemtable[i].chance
            if rand >= randitemchance then
                aux = aux + 1
                memo = randitemchance
            end
        end
    end

    local item = Tile(slots[#slots]):getTopDownItem()
    if item then
        item:remove()
    end

    local var1 = #slots
    for i = 1, #slots do
        var1 = var1 - 1
        if slots[var1] then
            local item = Tile(slots[var1]):getTopDownItem()
            if item then
                item:moveTo(slots[var1 + 1])
            end
        end
    end

    -- Criar o item antes de executar o efeito visual
    Game.createItem(itemtable[aux].id, 1, slots[1])

    -- Executar o efeito visual após criar o item
    for _, pos in ipairs(slots) do
        pos:sendMagicEffect(CONST_ME_ENERGYHIT)
    end
end

local novaRoleta = Action()
print('\27[1;32mROLETA: Carregada e Executada, Created by jhoncore modified, by Lostwalker\27[0m') -- jhoncore by Lostwalker
function novaRoleta.onUse(cid, item, target, position, fromPosition)
    local player = Player(cid)
    if not player then
        return false
    end
    if not player:removeItem(18423, 1) then -- esse item é o bilhete pra participar
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voce precisa de um ticket da roleta.")
        return false
    end
	local function ender(cid, position)
    local player = Player(cid)
    local posicaofim = Position(4368, 4028, 7)
    local item = Tile(posicaofim):getTopDownItem()
    if item then
        local itemId = item:getId()
        posicaofim:sendMagicEffect(CONST_ME_TUTORIALARROW)
        if player then
            player:addItem(itemId, 1)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "PARABEMS VC GANHOU UM(a) " .. ItemType(itemId):getName() .. "!")
        end
    end
    local alavanca = Tile(position):getTopDownItem()
    if alavanca then
        alavanca:setActionId(18563)
    end
end


    item:transform(decayItems[item.itemid])
    item:decay()	
    --muda actionid do item para nao permitir executar duas instancias
    item:setActionId(0)

    local speed = 20 -- aqui é a velocidade... quanto menor, mais rapido vai executar...
    local slowdown = 20 -- a cada execucao, esse valor de desaceleraçao vai aumentando. deixando a roleta mais lenta.. 
    local segundos = 20 -- quanto maior o tempo aqui, mais tempo vai ficar roletando os itens...

    local loopsize = segundos * 2

    local totaltimer = 0
    for i = 1, loopsize do
        addEvent(exec, (1 * i * speed), cid.uid)
        speed = speed + slowdown
        totaltimer = 1 * i * speed
    end
    addEvent(ender, (totaltimer) + 1000, cid.uid, fromPosition)

    return true
end

novaRoleta:aid(18563)
novaRoleta:register()