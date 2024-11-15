local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)            npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)        npcHandler:onCreatureDisappear(cid)            end
function onCreatureSay(cid, type, msg)        npcHandler:onCreatureSay(cid, type, msg)        end
function onThink()        npcHandler:onThink()        end

local voices = { {text = 'Passages to Thais, Enigma, Edron, Ankrahmun, Port Hope, Portland, Vigintia, Hydraland, Infernal and Roshamuul.'} }
npcHandler:addModule(VoiceModule:new(voices))

-- Travel
local function addTravelKeyword(keyword, cost, destination, action, condition)
    if condition then
        keywordHandler:addKeyword({keyword}, StdModule.say, {npcHandler = npcHandler, text = 'I\'m sorry but I don\'t sail there.'}, condition)
    end

    local travelKeyword = keywordHandler:addKeyword({keyword}, StdModule.say, {npcHandler = npcHandler, text = 'Do you seek a passage for ' .. cost .. ' gold?', cost = cost, discount = 'postman'})
        travelKeyword:addChildKeyword({'yes'}, function(cid, message, keywords, parameters)
            local player = Player(cid)
            if player:removeMoney(parameters.cost) then
                player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
                player:teleportTo(parameters.destination)
                parameters.destination:sendMagicEffect(CONST_ME_TELEPORT)
            else
                npcHandler:say('You do not have enough money.', cid)
            end
            npcHandler:resetNpc()
        end, {npcHandler = npcHandler, premium = false, cost = cost, discount = 'postman', destination = destination})
        travelKeyword:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, text = 'We would like to serve you some time.', reset = true})
end

addTravelKeyword('thais', 0, Position(4106, 4057, 6))
addTravelKeyword('enigma', 0, Position(4304, 4135, 6))
addTravelKeyword('porto real', 0, Position(4129, 4222, 7))
addTravelKeyword('hydraland', 0, Position(4171, 4228, 7))
addTravelKeyword('infernal', 0, Position(4281, 4276, 7))
addTravelKeyword('nightcrowley', 0, Position(4154, 4541, 7))
addTravelKeyword('okolnir', 0, Position(4424, 4394, 6))
addTravelKeyword('ankrahmun', 0, Position(4456, 4028, 6))
addTravelKeyword('roshamuul', 0, Position(4244, 5084, 7))  -- Adicionando Roshamuul
---- falta cadastrar port hope, edron e ethno

-- Basic
keywordHandler:addKeyword({'name'}, StdModule.say, {npcHandler = npcHandler, text = 'My name is Captain Bluebear from the Royal Tibia Line.'})
keywordHandler:addKeyword({'job'}, StdModule.say, {npcHandler = npcHandler, text = 'I am the captain of this sailing-ship.'})
keywordHandler:addKeyword({'captain'}, StdModule.say, {npcHandler = npcHandler, text = 'I am the captain of this sailing-ship.'})
keywordHandler:addKeyword({'ship'}, StdModule.say, {npcHandler = npcHandler, text = 'The Royal Tibia Line connects all seaside towns of Tibia.'})
keywordHandler:addKeyword({'line'}, StdModule.say, {npcHandler = npcHandler, text = 'The Royal Tibia Line connects all seaside towns of Tibia.'})
keywordHandler:addKeyword({'company'}, StdModule.say, {npcHandler = npcHandler, text = 'The Royal Tibia Line connects all seaside towns of Tibia.'})
keywordHandler:addKeyword({'tibia'}, StdModule.say, {npcHandler = npcHandler, text = 'The Royal Tibia Line connects all seaside towns of Tibia.'})
keywordHandler:addKeyword({'good'}, StdModule.say, {npcHandler = npcHandler, text = 'We can transport everything you want.'})
keywordHandler:addKeyword({'passenger'}, StdModule.say, {npcHandler = npcHandler, text = 'We would like to welcome you on board.'})
keywordHandler:addKeyword({'trip'}, StdModule.say, {npcHandler = npcHandler, text = 'Where do you want to go? To {Thais}, {Enigma}, {Ankrahmun}, {Porto Real}, {Okolnir}, {Hydraland}, {Roshamuul}, {Nightcrowley} or {Infernal}?'})
keywordHandler:addKeyword({'route'}, StdModule.say, {npcHandler = npcHandler, text = 'Where do you want to go? To {Thais}, {Enigma}, {Ankrahmun}, {Porto Real}, {Okolnir}, {Hydraland}, {Roshamuul}, {Nightcrowley} or {Infernal}?'})
keywordHandler:addKeyword({'passage'}, StdModule.say, {npcHandler = npcHandler, text = 'Where do you want to go? To {Thais}, {Enigma}, {Ankrahmun}, {Porto Real}, {Okolnir}, {Hydraland}, {Roshamuul}, {Nightcrowley} or {Infernal}?'})
keywordHandler:addKeyword({'town'}, StdModule.say, {npcHandler = npcHandler, text = 'Where do you want to go? To {Thais}, {Enigma}, {Ankrahmun}, {Porto Real}, {Okolnir}, {Hydraland}, {Roshamuul}, {Nightcrowley} or {Infernal}?'})
keywordHandler:addKeyword({'destination'}, StdModule.say, {npcHandler = npcHandler, text = 'Where do you want to go? To {Thais}, {Enigma}, {Ankrahmun}, {Porto Real}, {Okolnir}, {Hydraland}, {Roshamuul}, {Nightcrowley} or {Infernal}?'})
keywordHandler:addKeyword({'sail'}, StdModule.say, {npcHandler = npcHandler, text = 'Where do you want to go? To {Thais}, {Enigma}, {Ankrahmun}, {Porto Real}, {Okolnir}, {Hydraland}, {Roshamuul}, {Nightcrowley} or {Infernal}?'})
keywordHandler:addKeyword({'go'}, StdModule.say, {npcHandler = npcHandler, text = 'Where do you want to go? To {Thais}, {Enigma}, {Ankrahmun}, {Porto Real}, {Okolnir}, {Hydraland}, {Roshamuul}, {Nightcrowley} or {Infernal}?'})
keywordHandler:addKeyword({'ice'}, StdModule.say, {npcHandler = npcHandler, text = 'I\'m sorry, but we don\'t serve the routes to the Ice Islands.'})

npcHandler:setMessage(MESSAGE_GREET, 'Welcome on board, |PLAYERNAME|. Where can I {sail} you today?')
npcHandler:setMessage(MESSAGE_FAREWELL, 'Good bye. Recommend us if you were satisfied with our service.')
npcHandler:setMessage(MESSAGE_WALKAWAY, 'Good bye then.')

npcHandler:addModule(FocusModule:new())
