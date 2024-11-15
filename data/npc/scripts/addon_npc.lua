local keywordHandler = KeywordHandler:new() 
local npcHandler = NpcHandler:new(keywordHandler) 
NpcSystem.parseParameters(npcHandler) 

function onCreatureAppear(cid)            npcHandler:onCreatureAppear(cid)            end 
function onCreatureDisappear(cid)        npcHandler:onCreatureDisappear(cid)            end 
function onCreatureSay(cid, type, msg)    npcHandler:onCreatureSay(cid, type, msg)    end 
function onThink()                        npcHandler:onThink()    end 

-- Storage IDs -- 
citizen     = 22001  

newaddon    = 'Here you are, enjoy your brand new addon!' 
noitems        = 'You do not have all the required items.' 
already        = 'It seems you already have this addon, don\'t you try to mock me son!' 

function confirmAddon(cid)
    if getPlayerItemCount(cid, 5878) >= 100 then 
        if doPlayerRemoveItem(cid, 5878, 100) then 
            selfSay(newaddon, cid) 
            doSendMagicEffect(getCreaturePosition(cid), 13) 
            doPlayerAddOutfit(cid, 128, 1) 
            doPlayerAddOutfit(cid, 136, 1) 
            setPlayerStorageValue(cid, citizen, 1) 
        else 
            selfSay(noitems, cid) 
        end 
    else 
        selfSay(noitems, cid) 
    end 
end

function onCreatureSay(cid, type, msg)
    if msg:lower() == "hi" then
        npcHandler:say("To achieve the first citizen addon you need to give me 100 minotaur leathers. Do you have them with you?", cid)
        npcHandler.topic[cid] = 1
    elseif msg:lower() == "yes" and npcHandler.topic[cid] == 1 then
        confirmAddon(cid)
        npcHandler.topic[cid] = 0
    elseif msg:lower() == "no" and npcHandler.topic[cid] == 1 then
        npcHandler:say("Alright then.", cid)
        npcHandler.topic[cid] = 0
    end
    npcHandler:onCreatureSay(cid, type, msg)
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, onCreatureSay)
npcHandler:addModule(FocusModule:new())
