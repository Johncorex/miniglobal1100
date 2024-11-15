dofile('data/lib/core/json.lua')
dofile('data/scripts/tasks/taskSystemTables.lua')

taskPointStorage = 5151 
playerPointsStorage = 5152
uniqueTaskId = 5155 

currentKillStorage = 23345

for _, task in ipairs(configTasks) do
    task.killStorage = currentKillStorage
    currentKillStorage = currentKillStorage + 1
end

TaskSystem = {
    list = {},
    baseStorage = 1955,
    maximumTasks = 1,
    countForParty = true,
    maxDist = 7,
    players = {},
    loadDatabase = function()
        if (#TaskSystem.list > 0) then
            return true
        end
local monsters = Game.getMonsters()

function getMonsterLooktypeByName(monsterName)
    for _, monster in ipairs(monsters) do
        if monster:getName():lower() == monsterName:lower() then
            return monster:getOutfit().lookType
        end
    end

    return nil
end


function initializeTasksAndPoints()
     print("Initializing tasks and points...")


     for i = 1, #configTasks do
        table.insert(TaskSystem.list, {
            id = i,
            name = configTasks[i].nameOfTheTask,
            mobsToKill = configTasks[i].mobsToKill,
            looktype = configTasks[i].looktype,
            kills = configTasks[i].killsRequired,
            taskPoints = configTasks[i].pointsReward,
            exp = configTasks[i].expReward,
            realitem = configTasks[i].itemRewards,
            count = configTasks[i].itemRewardsCount,
            limit = 0,
            limitAtual = 0,
            points = playerPoints,  -- set to 0 initially
        })
    end

    for _, player in ipairs(Game.getPlayers()) do
        local playerPoints = player:getStorageValue(playerPointsStorage)
        for _, task in ipairs(TaskSystem.list) do
            if task.id == player:getStorageValue(playerCurrentTaskStorage) then
                if player:getStorageValue(playerCurrentTaskStorage) == -1 or player:getStorageValue(playerCurrentTaskStorage) == nil then
                    player:setStorageValue(playerCurrentTaskStorage, 0)
                end
                task.points = playerPoints
                break
            end
        end
    end
    print("Initialization complete.")
end

initializeTasksAndPoints()



        return true
    end,
    getCurrentTasks = function(player)
        local tasks = {}

        for _, task in ipairs(TaskSystem.list) do
            if (player:getStorageValue(TaskSystem.baseStorage + task.id) > 0) then
                local playerTask = task -- deepcopy(task)
                playerTask.left = player:getStorageValue(TaskSystem.baseStorage + task.id)
                playerTask.done = playerTask.kills - (playerTask.left - 1)
                table.insert(tasks, playerTask)
            end
        end

        return tasks
    end,
    getPlayerTaskIds = function(player)
        local tasks = {}

        for _, task in ipairs(TaskSystem.list) do
            if (player:getStorageValue(TaskSystem.baseStorage + task.id) > 0) then
                table.insert(tasks, task.id)
            end
        end

        return tasks
    end,
    getTaskNames = function(player)
        local tasks = {}

        for _, task in ipairs(TaskSystem.list) do
            table.insert(tasks, '{' .. task.name:lower() .. '}')
        end

        return table.concat(tasks, ', ')
    end,
    onAction = function(player, data)
         --print("Received action:", data['action'])  -- Add this line for debugging
if (data['action'] == 'info') then
            TaskSystem.sendData(player)
            TaskSystem.players[player.uid] = 1
        elseif (data['action'] == 'hide') then
            TaskSystem.players[player.uid] = nil
        elseif (data['action'] == 'start') then
            local playerTaskIds = TaskSystem.getPlayerTaskIds(player)
  print("Player task IDs:", table.concat(playerTaskIds, ', '))  -- Add this line for debugging

            if (#playerTaskIds == TaskSystem.maximumTasks) then
              print("Task limit reached. Unable to take more tasks.")  -- Add this line for debugging
              return player:sendExtendedJSONOpcode(215, {
                    message = "You can't take more tasks.",
                    color = 'red'
                })
            end

            for _, task in ipairs(TaskSystem.list) do
                if (task.id == data['entry']) then
                    if (table.contains(playerTaskIds, task.id)) then
                        return player:sendExtendedJSONOpcode(215, {
                            message = 'You already have this task active.',
                            color = 'red'
                        })
                    end

                    player:setStorageValue(TaskSystem.baseStorage + task.id, task.kills + 1)
                    player:sendExtendedJSONOpcode(215, {
                        message = 'Task started.',
                        color = 'green'
                    })

                    return TaskSystem.sendData(player)
                end
            end

            return player:sendExtendedJSONOpcode(215, {
                message = 'Unknown task.',
                color = 'red'
            })
        elseif (data['action'] == 'cancel') then
            for _, task in ipairs(TaskSystem.list) do
                if (task.id == data['entry']) then
                    local playerTaskIds = TaskSystem.getPlayerTaskIds(player)
  print("Player task IDs:", table.concat(playerTaskIds, ', '))  -- Add this line for debugging

                    if (not table.contains(playerTaskIds, task.id)) then
                        return player:sendExtendedJSONOpcode(215, {
                            message = "You don't have this task active.",
                            color = 'red'
                        })
                    end

                    player:setStorageValue(TaskSystem.baseStorage + task.id, -1)
                    player:sendExtendedJSONOpcode(215, {
                        message = 'Task aborted.',
                        color = 'green'
                    })

                    return TaskSystem.sendData(player)
                end
            end

            return player:sendExtendedJSONOpcode(215, {
                message = 'Unknown task.',
                color = 'red'
            })
        elseif (data['action'] == 'finish') then
            for _, task in ipairs(TaskSystem.list) do
                if (task.id == data['entry']) then
                    local playerTaskIds = TaskSystem.getPlayerTaskIds(player)

                    if (not table.contains(playerTaskIds, task.id)) then
                        return player:sendExtendedJSONOpcode(215, {
                            message = "You don't have this task active.",
                            color = 'red'
                        })
                    end

                    local left = player:getStorageValue(TaskSystem.baseStorage + task.id)

                    if (left > 1) then
                        return player:sendExtendedJSONOpcode(215, {
                            message = "Task isn't completed yet.",
                            color = 'red'
                        })
                    end

                    player:setStorageValue(TaskSystem.baseStorage + task.id, -1)
                    player:addExperience(task.exp)
                    player:addItem(task.realitem, task.count) 

                    player:setStorageValue(playerPointsStorage, player:getStorageValue(playerPointsStorage) + task.taskPoints)
                    player:setStorageValue(taskPointStorage, (player:getStorageValue(taskPointStorage) + task.taskPoints))
                    player:sendExtendedJSONOpcode(215, {
                        message = 'Task finished.',
                        color = 'green'
                    })
                    return TaskSystem.sendData(player)
                end
            end

            return player:sendExtendedJSONOpcode(215, {
                message = 'Unknown task.',
                color = 'red'
            })
        end
    end,
    killForPlayer = function(player, task)
    local left = player:getStorageValue(TaskSystem.baseStorage + task.id)

    if (left == 1) then
        if (TaskSystem.players[player.uid]) then
            player:sendExtendedJSONOpcode(215, {
                message = 'Task finished.',
                color = 'green'
            })
        end

        return true
    end

    player:setStorageValue(TaskSystem.baseStorage + task.id, left - 1)

    if (TaskSystem.players[player.uid]) then
        return TaskSystem.sendData(player)
    end
end,
onKill = function(player, target)
    local targetName = target:getName():lower()

    for _, task in ipairs(TaskSystem.list) do
        for _, mob in ipairs(task.mobsToKill) do
            if mob:lower() == targetName then
                local playerTaskIds = TaskSystem.getPlayerTaskIds(player)

                if (not table.contains(playerTaskIds, task.id)) then
                    return true
                end

                local party = player:getParty()
                local tpos = target:getPosition()

                if (TaskSystem.countForParty and party and party:getMembers()) then
                    for i, creature in pairs(party:getMembers()) do
                        local pos = creature:getPosition()

                        if (pos.z == tpos.z and pos:getDistance(tpos) <= TaskSystem.maxDist) then
                            TaskSystem.killForPlayer(creature, task)
                        end
                    end

                    local pos = party:getLeader():getPosition()

                    if (pos.z == tpos.z and pos:getDistance(tpos) <= TaskSystem.maxDist) then
                        TaskSystem.killForPlayer(party:getLeader(), task)
                    end
                else
                    TaskSystem.killForPlayer(player, task)

                    local mobsToKillStr = table.concat(task.mobsToKill, ", ")
                    player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Você matou um monstro da task, os monstros válidos são: " .. mobsToKillStr)
                end

                return true
            end
        end
    end
end
,
sendData = function(player)
    local playerTasks = TaskSystem.getCurrentTasks(player)
    
    local response = {
 --           boost1 = ''..Game.getBoostMonster()..'',
 --           boost2 = ''..Game.getBoostMonsterSecond()..'',
 --          boost3 = ''..Game.getBoostMonsterThird()..'',
 --           boostBoss = ''..Game.getBoostBoss()..'',

--           boost1 = '',
--            boost2 = '',
--           boost3 = '',
--           boostBoss = '',
        pointsGeneral =  player:getStorageValue(playerPointsStorage),
        allTasks = TaskSystem.list,
        playerTasks = playerTasks
    }
    player:sendExtendedJSONOpcode(215, response)
end
}


local events = {}

local globalevent = GlobalEvent('Tasks')

function globalevent.onStartup()
    return TaskSystem.loadDatabase()
end

table.insert(events, globalevent)

local creatureevent = CreatureEvent('TaskKill')

function creatureevent.onKill(creature, target)
    if (not creature:isPlayer() or not Monster(target)) then
        return true
    end

    TaskSystem.onKill(creature, target)

    return true
end

table.insert(events, creatureevent)

for _, event in ipairs(events) do
    event:register()
end



function completeTask(player, task)
    player:setStorageValue(task.killStorage, player:getStorageValue(task.killStorage) + 1)
end

function shouldDisplayTask(player, task)
    local currentKills = player:getStorageValue(task.killStorage)
    return currentKills
end

function showTaskWindow(player)
    local taskWindow = "Tarefas Disponíveis:\n"

    for _, task in ipairs(configTasks) do
        local currentKills = player:getStorageValue(task.killStorage)

        taskWindow = taskWindow .. "\n" .. task.nameOfTheTask .. ": " .. currentKills .. "/" .. task.killsRequired .. " kills"
    end

    -- Exemplo: use player:sendTextMessage ou outra função para exibir a janela ao jogador
    player:sendTextMessage(MESSAGE_INFO_DESCR, taskWindow)
end


-- Adiciona essa função no bloco de código
function getCompletedTasksCount(player, taskId)
    return player:getStorageValue(TaskSystem.baseStorage + taskId)
end

function getPlayerPoints(player)
    return player:getStorageValue(playerPointsStorage)
end


function resetAllTasks(player)
    for _, task in ipairs(TaskSystem.list) do
        player:setStorageValue(TaskSystem.baseStorage + task.id, -1)
    end

    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "All tasks reset.")
    return TaskSystem.sendData(player)
end


function isTaskLimitReached(player, task)
    local completedCount = getCompletedTasksCount(player, task.id)
    return completedCount >= task.limit
end

function canAcceptTask(player, task)
    return not isTaskLimitReached(player, task)
end

function isTaskAccomplished(player, task)
    local completedCount = getCompletedTasksCount(player, task.id)
    return completedCount > 0
end

-- Modifica a função onAction para incluir as verificações adicionais
onAction = function(player, data)
        if data['action'] == 'info' then
            TaskSystem.sendData(player)
            TaskSystem.players[player.uid] = 1
        elseif data['action'] == 'hide' then
            TaskSystem.players[player.uid] = nil
        elseif data['action'] == 'start' then
            local playerTaskIds = TaskSystem.getPlayerTaskIds(player)

            if #playerTaskIds >= TaskSystem.maximumTasks then
                print("Task limit reached. Unable to take more tasks.")
                return player:sendExtendedJSONOpcode(215, {
                    message = "You can't take more tasks.",
                    color = 'red'
                })
            end

            for _, task in ipairs(TaskSystem.list) do
                if task.id == data['entry'] then
                    if not canAcceptTask(player, task) then
                        print("Task limit reached for this task.")
                        return player:sendExtendedJSONOpcode(215, {
                            message = 'Task limit reached.',
                            color = 'red'
                        })
                    end

                    if table.contains(playerTaskIds, task.id) then
                        print("Player already has this task active.")
                        return player:sendExtendedJSONOpcode(215, {
                            message = 'You already have this task active.',
                            color = 'red'
                        })
                    end

                    player:setStorageValue(TaskSystem.baseStorage + task.id, task.kills + 1)
                    player:sendExtendedJSONOpcode(215, {
                        message = 'Task started.',
                        color = 'green'
                    })
                    print("Task started for player.")
                    return TaskSystem.sendData(player)
                end
            end

            return player:sendExtendedJSONOpcode(215, {
                message = 'Unknown task.',
                color = 'red'
            })
        elseif data['action'] == 'cancel' then
            -- Existing code...
        elseif data['action'] == 'finish' then
            for _, task in ipairs(TaskSystem.list) do
                if task.id == data['entry'] then
                local playerTaskIds = TaskSystem.getPlayerTaskIds(player)

                if not table.contains(playerTaskIds, task.id) then
                    return player:sendExtendedJSONOpcode(215, {
                        message = "You don't have this task active.",
                        color = 'red'
                    })
                end

                player:setStorageValue(playerPointsStorage, player:getStorageValue(playerPointsStorage) + task.pointsReward)
                player:setStorageValue(TaskSystem.baseStorage + task.id, -1)
                player:sendExtendedJSONOpcode(215, {
                    message = 'Task aborted.',
                    color = 'green'
                })

                return TaskSystem.sendData(player)
            end
        end
        print("Unknown task.")
        return player:sendExtendedJSONOpcode(215, {
            message = 'Unknown task.',
            color = 'red'
        })
    elseif data['action'] == 'finish' then
        for _, task in ipairs(TaskSystem.list) do
            if task.id == data['entry'] then
                local playerTaskIds = TaskSystem.getPlayerTaskIds(player)

                if not table.contains(playerTaskIds, task.id) then
                    return player:sendExtendedJSONOpcode(215, {
                        message = "You don't have this task active.",
                        color = 'red'
                    })
                end

                local left = player:getStorageValue(TaskSystem.baseStorage + task.id)

                if left > 1 then
                    return player:sendExtendedJSONOpcode(215, {
                        message = "Task isn't completed yet.",
                        color = 'red'
                    })
                end

                player:setStorageValue(TaskSystem.baseStorage + task.id, -1)
                player:addExperience(task.exp)

                if task.itemRewards and task.itemRewardsCount then
                    local reward = player:addItem(task.realitem, task.count, true)
                    reward:setActionId(uniqueTaskId)
                else
                    local reward = player:addItem(task.realitem, task.count, true)
                    reward:setActionId(uniqueTaskId)
                end
                    if task.pointsReward then
                        player:setStorageValue(playerPointsStorage, getPlayerPoints(player) + task.pointsReward)
                    else
                        player:setStorageValue(playerPointsStorage, getPlayerPoints(player) + 0)
                    end

player:setStorageValue(taskPointStorage, (player:getStorageValue(taskPointStorage) + task.taskPoints))
player:sendExtendedJSONOpcode(215, {
                    message = 'Task finished.',
                    color = 'green'
                })

                if isTaskAccomplished(player, task) then
                    player:sendExtendedJSONOpcode(215, {
                        message = 'Task already accomplished.',
                        color = 'yellow'
                    })
                end
                print("Task finished for player.")
                return TaskSystem.sendData(player)
            end
        end

        print("Unknown action.")
        return player:sendExtendedJSONOpcode(215, {
                message = 'Unknown task.',
                color = 'red'
            })
    end
end
