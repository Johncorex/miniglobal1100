local testtexttopplayers = GlobalEvent("textfloat")

local positions = {
    {pos = Position(4165, 4091, 7), effect = 62},
    {pos = Position(4163, 4093, 7), effect = 62},
    {pos = Position(4167, 4093, 7), effect = 62}
}

function testtexttopplayers.onThink(interval)
    local getTopPlayers = function(amount)
        local query = string.format("SELECT `name`, `level`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `lookaddons` FROM `players` ORDER BY `level` DESC, `experience` DESC LIMIT %d", amount)
        local resultId = db.storeQuery(query)
        local players = {}
        if resultId then
            repeat
                local name = result.getDataString(resultId, "name")
                local level = result.getDataInt(resultId, "level")
                local outfit = {
                    lookBody = result.getDataInt(resultId, "lookbody"),
                    lookFeet = result.getDataInt(resultId, "lookfeet"),
                    lookHead = result.getDataInt(resultId, "lookhead"),
                    lookLegs = result.getDataInt(resultId, "looklegs"),
                    lookType = result.getDataInt(resultId, "looktype"),
                    lookAddons = result.getDataInt(resultId, "lookaddons")
                }
                table.insert(players, {name = name, level = level, outfit = outfit})
            until not result.next(resultId)
            result.free(resultId)
        end
        return players
    end

    local topPlayers = getTopPlayers(3)
    for i, positionData in ipairs(positions) do
        local topPlayer = topPlayers[i]
        if topPlayer then
            local message = string.format("Top Level %d: %s [%d]", i, topPlayer.name, topPlayer.level)
            local spectators = Game.getSpectators(positionData.pos, false, true, 7, 7, 5, 5)
            for _, spectator in ipairs(spectators) do
                if spectator:isPlayer() then
                    spectator:say(message, TALKTYPE_MONSTER_SAY, false, spectator, positionData.pos)
                end
            end
            local dummy = Game.createMonster("Player", positionData.pos, false, true)
            if dummy then
                local outfit = topPlayer.outfit
                dummy:setOutfit(outfit)
                dummy:rename(topPlayer.name)
                addEvent(function() dummy:remove() end, 5000)
            end
            positionData.pos:sendMagicEffect(positionData.effect)
        else
            local message = string.format("Top Level %d: None", i)
            positionData.pos:sendMagicEffect(positionData.effect)
            local spectators = Game.getSpectators(positionData.pos, false, true, 7, 7, 5, 5)
            for _, spectator in ipairs(spectators) do
                if spectator:isPlayer() then
                    spectator:say(message, TALKTYPE_MONSTER_SAY, false, spectator, positionData.pos)
                end
            end
        end
    end
    return true
end


testtexttopplayers:interval(5000)
testtexttopplayers:register()