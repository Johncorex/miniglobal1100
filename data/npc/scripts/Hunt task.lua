local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)			npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)		npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()		npcHandler:onThink()		end

local voices = { {text = '[HUNT TASK] Ofereço serviços especiais para sua task. basta falar hi - cavelist e escolher, vem cabeção. '} }
npcHandler:addModule(VoiceModule:new(voices))

-- Travel
local function addTravelKeyword(keyword, cost, destination, action, condition)
	if condition then
		keywordHandler:addKeyword({keyword}, StdModule.say, {npcHandler = npcHandler, text = 'I\'m sorry but I don\'t sail there.'}, condition)
	end

	local travelKeyword = keywordHandler:addKeyword({keyword}, StdModule.say, {npcHandler = npcHandler, text = 'Do you seek a passage to ' .. keyword:titleCase() .. ' for |TRAVELCOST|?', cost = cost, discount = 'postman'})
		travelKeyword:addChildKeyword({'yes'}, StdModule.travel, {npcHandler = npcHandler, premium = false, cost = cost, discount = 'postman', destination = destination}, nil, action)
		travelKeyword:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, text = 'We would like to serve you some time.', reset = true})
end

addTravelKeyword('necromancers', 0, Position(5389, 4417, 6))
addTravelKeyword('hero', 0, Position(5573, 4360, 6))
addTravelKeyword('pirate', 0, Position(4087, 3945, 6))
addTravelKeyword('hydra', 0, Position(5389, 4513, 7))
addTravelKeyword('dwarf', 0, Position(5567, 4537, 8))
addTravelKeyword('rat', 0, Position(5657, 4520, 7))
addTravelKeyword('dragons', 0, Position(5809, 4679, 7))
addTravelKeyword('demon', 0, Position(5460, 4699, 7))
addTravelKeyword('giant spider', 0, Position(5402, 4684, 7))
addTravelKeyword('crystal spider', 0, Position(5427, 4754, 7))
addTravelKeyword('minotaur', 0, Position(5381, 4812, 7))
addTravelKeyword('rotworm', 0, Position(5706, 4826, 6))

-- Basic
keywordHandler:addKeyword({'trip'}, StdModule.say, {npcHandler = npcHandler, text = 'Where do you want to go? To {necromancers}, {hero}, {pirate}, {hydra}, {dragon}, {rat}, {demon}, {dwarf}, {rotworm}{giant spider}, {minotaur} or {crystal spider}?'})
keywordHandler:addKeyword({'route'}, StdModule.say, {npcHandler = npcHandler, text = 'Where do you want to go? To {necromancers}, {hero}, {pirate}, {hydra}, {dragon}, {rat}, {demon}, {dwarf}, {rotworm} {giant spider}, {minotaur} or {crystal spider}?'})
keywordHandler:addKeyword({'passage'}, StdModule.say, {npcHandler = npcHandler, text = 'Where do you want to go? To {necromancers}, {hero}, {pirate}, {hydra}, {dragon}, {rat}, {demon}, {dwarf}, {rotworm} {giant spider}, {minotaur} or {crystal spider}?'})
keywordHandler:addKeyword({'cavelist'}, StdModule.say, {npcHandler = npcHandler, text = 'Quais desses locais você gostaria de conhecer? {necromancers}, {hero}, {pirate}, {hydra}, {dragon}, {rat}, {demon}, {dwarf}, {rotworm} {giant spider}, {minotaur} ou {crystal spider}?'})
keywordHandler:addKeyword({'town'}, StdModule.say, {npcHandler = npcHandler, text = 'Where do you want to go? Ttoo {necromancers}, {hero}, {pirate}, {hydra}, {dragon}, {rat}, {demon}, {dwarf}, {rotworm} {giant spider}, {minotaur} or {crystal spider}?'})
keywordHandler:addKeyword({'destination'}, StdModule.say, {npcHandler = npcHandler, text = 'Where do you want  go? To {necromancers}, {hero}, {pirate}, {hydra}, {dragon}, {rat}, {demon}, {dwarf}, {rotworm} {giant spider}, {minotaur} or {crystal spider}?'})
keywordHandler:addKeyword({'sail'}, StdModule.say, {npcHandler = npcHandler, text = 'Where do you want to go? To {necromancers}, {hero}, {pirate}, {hydra}, {dragon}, {rat}, {demon}, {dwarf}, {rotworm} {giant spider}, {minotaur} or {crystal spider}?'})
keywordHandler:addKeyword({'go'}, StdModule.say, {npcHandler = npcHandler, text = 'Where do you want to go? To {necromancers}, {hero}, {pirate}, {hydra}, {dragon}, {rat}, {demon}, {dwarf}, {rotworm}, {giant spider}, {minotaur} or {crystal spider}?'})

npcHandler:setMessage(MESSAGE_GREET, 'Olá aventureiro(a), |PLAYERNAME|. baum?  eu ofereço viagens para varios locais nunca antes visto, com caves gigantes e muito interessantes para você poder concretizar suas Hunt Tasks. Basta você me falar {cavelist} e escolher uma delas.. que eu te levo para conhecer blz.')
npcHandler:setMessage(MESSAGE_FAREWELL, 'Xau caro aventureiro. ei po dispense, recomenda meus serviços pra galera ai blz.')
npcHandler:setMessage(MESSAGE_WALKAWAY, 'xau ate logo cabeção, ver se divulga meus serviços em, aqui é o melhor da região arenaot.')
npcHandler:addModule(FocusModule:new())
