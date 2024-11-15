function summonMonsters(position)
    local monsterTypes = {"Dragon Hatchling", "Dragon", "Dragon Lord Hatchling", "Dragon Lord"}
    local numMonsters = math.random(1, 3)
    for i = 1, numMonsters do
        local randomMonster = monsterTypes[math.random(#monsterTypes)]
        doSummonCreature(randomMonster, position)
    end
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local pos = getPlayerPosition(cid)
    if fromPosition.x ~= CONTAINER_POSITION and item.itemid == 15501 then
        doTransformItem(item.uid, 15502)
        summonMonsters(fromPosition)
        addEvent(function()
            local item = getTileItemById(fromPosition, 15502)
            if item.uid > 0 then
                doTransformItem(item.uid, 15501)
            end
        end, 3600 * 1000) -- 3600 segundos = 1 hora
    elseif fromPosition.x == CONTAINER_POSITION and item.itemid == 15501 then
        doPlayerSendCancel(cid, "You may open this only on the ground.")
    end

    return true
end

function onStepIn(cid, item, position, fromPosition)
    if item.itemid == 15501 then
        doTransformItem(item.uid, 15502)
        summonMonsters(position)
        addEvent(function()
            local item = getTileItemById(position, 15502)
            if item.uid > 0 then
                doTransformItem(item.uid, 15501)
            end
        end, 3600 * 1000) -- 3600 segundos = 1 hora
    end

    return true
end
