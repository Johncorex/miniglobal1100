--[[
	MARK: HunterSystem
	Author: @MillhioreBT
	Version: 1.0
]] --
---
---@enum HunterStatus
HunterStatus = {
	ACTIVE = 0,
	FINISHED = 1
}
---
---@class (exact) HunterSystem
---@field command string
---@field commission integer
---@field refund integer
---@field maxTimeHunted integer
---@field chunkSize integer
---@field loaded boolean
---@field forceSave boolean
---@field cache table<integer, table<integer, Hunter>>
HunterSystem = {
	command = "!hunted",
	commission = 10, -- 10%
	refund = 50, -- 50%
	chunkSize = 10,
	maxTimeHunted = 60 * 60 * 24 * 7, -- 7 days
	loaded = HunterSystem and HunterSystem.loaded or false,
	forceSave = false,
	cache = HunterSystem and HunterSystem.cache or {}
}

local fmt = string.format

---@ SQL Query
local function createTable()
	local query = [[
		create table if not exists `hunter_system` (
			`id` int not null auto_increment,
			`owner` int not null,
			`target` int not null,
			`status` int not null,
			`reward_gold` int not null,
			`created_at` timestamp not null default current_timestamp,
			`updated_at` timestamp not null default current_timestamp on update current_timestamp,
			`finished_at` timestamp null,
			primary key (`id`)
		);
	]]

	if not db.query(query) then
		debugPrint("[HuntedSystem] Error while creating table: `hunter_system`")
		return false
	end
	return true
end

local globalEvent = GlobalEvent("HunterSystemLoad")

function globalEvent.onStartup()
	if not createTable() then
		print("[HuntedSystem] Error while creating table")
		return false
	end

	if not HunterSystem:loadAllHunters() then
		print("[HuntedSystem] Warning while loading hunters")
	end
	return true
end

globalEvent:register()

---@param owner integer
function HunterSystem:loadHunters(owner)
	if self.cache[owner] then return true end

	local query = [[
		SELECT `owner`, `target`, `status`, `reward_gold`, UNIX_TIMESTAMP(`created_at`) AS `created_at`,
			UNIX_TIMESTAMP(`updated_at`) AS `updated_at`, UNIX_TIMESTAMP(`finished_at`) AS `finished_at` FROM `hunter_system` WHERE `owner` = %d;
	]]

	local store = db.storeQuery(fmt(query, owner))
	if not store then return false end

	---@type table<integer, Hunter>
	local hunters = {}
	repeat
		---@type Hunter
		local hunter = setmetatable({
			owner = result.getNumber(store, "owner"),
			target = result.getNumber(store, "target"),
			status = result.getNumber(store, "status"),
			rewardGold = result.getNumber(store, "reward_gold"),
			createdAt = result.getNumber(store, "created_at"),
			updatedAt = result.getNumber(store, "updated_at"),
			finishedAt = result.getNumber(store, "finished_at")
		}, Hunter)
		hunters[#hunters + 1] = hunter
	until not result.next(store)
	result.free(store)

	self.cache[owner] = hunters
	return true
end

---@param owner integer
function HunterSystem:saveHunters(owner)
	local hunters = self.cache[owner]
	if not hunters then return true end

	local transaction = DBTransaction()
	if not transaction:begin() then
		debugPrint("[HuntedSystem] Error while creating transaction")
		return false
	end

	local query = "DELETE FROM `hunter_system` WHERE `owner` = %d;"
	if not db.query(fmt(query, owner)) then
		debugPrint("[HuntedSystem] Error while deleting hunters")
		return false
	end

	local insert = DBInsert(
		"INSERT INTO `hunter_system` (`owner`, `target`, `status`, `reward_gold`, `created_at`, `updated_at`, `finished_at`) VALUES")
	for _, hunter in ipairs(hunters) do
		if not hunter:isExpired() then
			insert:addRow(fmt(
				"%d, %d, %d, %d, FROM_UNIXTIME(%d), FROM_UNIXTIME(%d), FROM_UNIXTIME(%d)",
				hunter.owner, hunter.target, hunter.status, hunter.rewardGold, hunter.createdAt,
				hunter.updatedAt, hunter.finishedAt))
		end
	end

	if not insert:execute() then
		debugPrint("[HuntedSystem] Error while inserting hunters")
		return false
	end

	return transaction:commit()
end

---@param owner integer
---@param target integer
---@param rewardGold integer
function HunterSystem:addHunter(owner, target, rewardGold)
	local hunters = self.cache[owner]
	if not hunters then
		hunters = {}
		self.cache[owner] = hunters
	end

	for _, hunter in ipairs(hunters) do
		if hunter.target == target then
			return false
		end
	end

	local timeNow = os.time()
	local hunter = setmetatable({
		owner = owner,
		target = target,
		status = HunterStatus.ACTIVE,
		rewardGold = rewardGold,
		createdAt = timeNow,
		updatedAt = timeNow,
		finishedAt = timeNow + self.maxTimeHunted
	}, Hunter)

	hunters[#hunters + 1] = hunter
	return true
end

---@param hunter Hunter
function HunterSystem:removeHunter(hunter)
	local hunters = self.cache[hunter.owner]
	if not hunters then
		return false
	end

	for i, h in ipairs(hunters) do
		if h == hunter then
			table.remove(hunters, i)
			return true
		end
	end
	return false
end

---@param owner integer
---@param target integer
function HunterSystem:isExists(owner, target)
	local hunters = self.cache[owner]
	if hunters then
		for _, hunter in ipairs(hunters) do
			if hunter.status == HunterStatus.ACTIVE and not hunter:isExpired() and hunter.target == target then
				return true
			end
		end
	end
	return false
end

function HunterSystem:loadAllHunters()
	if self.loaded then return true end

	local owners = db.storeQuery("SELECT DISTINCT `owner` FROM `hunter_system`")
	if not owners then return false end

	repeat self:loadHunters(result.getNumber(owners, "owner")) until not result.next(owners)
	result.free(owners)
	self.loaded = true
	return true
end

---@param name string
---@return integer?
function HunterSystem:getOwnerByName(name)
	local player = Player(name)
	if player then return player:getGuid() end

	local store = db.storeQuery(fmt("SELECT `id` FROM `players` WHERE `name` = %s;",
		db.escapeString(name)))
	if not store then return end

	local id = result.getNumber(store, "id")
	result.free(store)
	return id
end

---@param owner integer
---@return string?
function HunterSystem:getNameByOwner(owner)
	local player = Player(owner)
	if player then return player:getName() end

	local store = db.storeQuery(fmt("SELECT `name` FROM `players` WHERE `id` = %d;", owner))
	if not store then return end

	local name = result.getString(store, "name")
	result.free(store)
	return name
end

do
	---@param modalWindow ModalWindow
	---@param hunters table<integer, Hunter>
	---@param min integer
	---@param max integer
	local function addModalWindowChoices(modalWindow, hunters, min, max)
		for i = min, max do
			local hunter = hunters[i]
			if hunter then
				local targetName = HunterSystem:getNameByOwner(hunter.target) or "Unknown"
				if targetName then
					modalWindow:addChoice(fmt("%s - %d gold coins", targetName, hunter.rewardGold))
				end
			end
		end
	end

	---@type function
	local addModalWindowBackButton = nil
	---@type function
	local addModalWindowNextButton = nil

	---@param modalWindow ModalWindow
	---@param hunters table<integer, Hunter>
	---@param min integer
	---@param max integer
	addModalWindowBackButton = function(modalWindow, hunters, min, max)
		if min > HunterSystem.chunkSize then
			modalWindow:addButton("Back", function(player, button, choice)
				modalWindow:clearChoices()
				modalWindow:clearButtons()

				max = min - 1
				min = math.max(max - HunterSystem.chunkSize + 1, 1)

				addModalWindowChoices(modalWindow, hunters, min, max)
				addModalWindowBackButton(modalWindow, hunters, min, max)
				addModalWindowNextButton(modalWindow, hunters, min, max)
				modalWindow:addButton("Close")
				modalWindow:sendToPlayer(player)
				return true
			end)
		end
	end

	---@param modalWindow ModalWindow
	---@param hunters table<integer, Hunter>
	---@param min integer
	---@param max integer
	addModalWindowNextButton = function(modalWindow, hunters, min, max)
		if max < #hunters then
			modalWindow:addButton("Next", function(player, button, choice)
				modalWindow:clearChoices()
				modalWindow:clearButtons()

				min = max + 1
				max = math.min(min + HunterSystem.chunkSize - 1, #hunters)

				addModalWindowChoices(modalWindow, hunters, min, max)
				addModalWindowBackButton(modalWindow, hunters, min, max)
				addModalWindowNextButton(modalWindow, hunters, min, max)
				modalWindow:addButton("Close")
				modalWindow:sendToPlayer(player)
				return true
			end)
		end
	end

	---@param modalWindow ModalWindow
	---@param hunters table<integer, Hunter>
	---@param min integer
	---@param max integer
	function HunterSystem:loadModalChunkHunters(modalWindow, hunters, min, max)
		addModalWindowChoices(modalWindow, hunters, min, max)
		addModalWindowBackButton(modalWindow, hunters, min, max)
		addModalWindowNextButton(modalWindow, hunters, min, max)
		modalWindow:addButton("Close")
	end
end

---@param target integer
---@return table<integer, Hunter>
function HunterSystem:getHuntersByTarget(target)
	local hunters = {}
	for _, hs in pairs(self.cache) do
		for _, hunter in ipairs(hs) do
			if hunter.status == HunterStatus.ACTIVE and not hunter:isExpired() and hunter.target == target then
				hunters[#hunters + 1] = hunter
			end
		end
	end
	return hunters
end

---@param owner integer
---@return table<integer, Hunter>
function HunterSystem:getValidHunters(owner)
	local hunters = self.cache[owner]
	if not hunters then return {} end

	local validHunters = {}
	for _, hunter in ipairs(hunters) do
		if hunter.status == HunterStatus.ACTIVE and not hunter:isExpired() then
			validHunters[#validHunters + 1] = hunter
		end
	end
	return validHunters
end

---@return table<integer, Hunter>
function HunterSystem:getAllValidHunters()
	local hunters = {}
	for _, hs in pairs(self.cache) do
		for _, hunter in ipairs(hs) do
			if hunter.status == HunterStatus.ACTIVE and not hunter:isExpired() then
				hunters[#hunters + 1] = hunter
			end
		end
	end
	return hunters
end

-- MARK: Hunter
---@class (exact) Hunter
---@field owner integer
---@field target integer
---@field status HunterStatus
---@field rewardGold integer
---@field createdAt integer
---@field updatedAt integer
---@field finishedAt integer
---@field __index Hunter
Hunter = {}
Hunter.__index = Hunter

function Hunter:isExpired() return os.time() >= self.finishedAt end

-- MARK: Events

local creatureEvent = CreatureEvent("HunterSystemLogin")

function creatureEvent.onLogin(player)
	player:registerEvent("HunterSystemDeath")
	if not HunterSystem:loadHunters(player:getGuid()) then
		return true
	end
	return true
end

creatureEvent:register()

local creatureEvent = CreatureEvent("HunterSystemLogout")

function creatureEvent.onLogout(player)
	if not HunterSystem:saveHunters(player:getGuid()) then
		debugPrint("[HunterSystem] Error while saving hunters")
	end
	return true
end

creatureEvent:register()

---@param t table<integer, any>
local shuffle = function(t)
	local n = #t
	while n > 2 do
		local k = math.random(n)
		t[n], t[k] = t[k], t[n]
		n = n - 1
	end
	return t
end

---@param count number?
local function checkCount(count)
	if not count then return -1 end

	if count > 2 ^ 32 - 1 then
		print("Warning: Casting value to 32bit to prevent crash\n" .. debug.traceback())
	end
	return math.min(2 ^ 32 - 1, count)
end

---@param str string
local function getCount(str)
	local b, e = str:find("%d+")
	if not b or not e then
		return -1
	end
	return checkCount(tonumber(str:sub(b, e)))
end

---@generic T
---@param value T
---@param n integer
---@return T ...
local function repeat_values(value, n)
	local values = {}
	for i = 1, n do
		values[i] = value
	end
	return unpack(values)
end

local talkAction = TalkAction(HunterSystem.command)

function talkAction.onSay(player, words, param, type)
	local splitTrimmed = param:splitTrimmed(",")
	local action = splitTrimmed[1] and splitTrimmed[1]:lower()

	-- MARK: ADD
	if action == "add" then
		local target = HunterSystem:getOwnerByName(splitTrimmed[2])
		if not target then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Player not found.")
			return false
		end

		if target == player:getGuid() then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You can't hunt yourself.")
			return false
		end

		if HunterSystem:isExists(player:getGuid(), target) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
				"You are already hunting this player.")
			return false
		end

		local rewardGold = getCount(splitTrimmed[3])
		if rewardGold <= 0 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Invalid reward gold.")
			return false
		end

		rewardGold = math.floor(rewardGold * (1 + HunterSystem.commission / 100))
		if checkCount(rewardGold) <= 0 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Invalid reward gold.")
			return false
		end

		if player:getTotalMoney() < rewardGold then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You don't have enough gold coins.")
			return false
		end

		if not player:removeTotalMoney(rewardGold) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Error while removing gold coins.")
			return false
		end

		if not HunterSystem:addHunter(player:getGuid(), target, rewardGold) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Error while adding hunter.")
			return false
		end

		local targetName = HunterSystem:getNameByOwner(target) or "Unknown"
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Hunted added.")
		Game.broadcastMessage(fmt("%s started hunted %s for %d gold coins.", player:getName(),
			targetName, rewardGold), MESSAGE_EVENT_ADVANCE)
		return false
	end

	-- MARK: REMOVE
	if action == "remove" then
		local target = HunterSystem:getOwnerByName(splitTrimmed[2])
		if not target then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Player not found.")
			return false
		end

		local hunters = HunterSystem:getValidHunters(player:getGuid())
		if not hunters then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You are not hunting this player.")
			return false
		end

		---@type Hunter?
		local found = nil
		for _, hunter in ipairs(hunters) do
			if hunter.target == target then
				if not HunterSystem:removeHunter(hunter) then
					player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
						"Error while removing hunter.")
					return false
				end

				found = hunter
				break
			end
		end

		if found then
			local refoundGold = math.floor(found.rewardGold * HunterSystem.refund / 100)
			if checkCount(refoundGold) <= 0 then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Error while calculating refund.")
				return false
			end

			if player:canCarryMoney(refoundGold) then
				player:addMoney(refoundGold)
			else
				player:setBankBalance(player:getBankBalance() + refoundGold)
			end

			local targetName = HunterSystem:getNameByOwner(target) or "Unknown"
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
				fmt("Hunted removed. Refund: %d gold coins.",
					refoundGold))
			Game.broadcastMessage(fmt("%s stopped hunting %s.", player:getName(), targetName),
				MESSAGE_EVENT_ADVANCE)

			if HunterSystem.forceSave and not HunterSystem:saveHunters(player:getGuid()) then
				debugPrint("[HuntedSystem] Error while saving hunters")
			end
			return false
		end

		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You are not hunting this player.")
		return false
	end

	-- MARK: LIST
	if action == "list" then
		local target = HunterSystem:getOwnerByName(splitTrimmed[2])
		if not target then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Player not found.")
			return false
		end

		local hunters = HunterSystem:getValidHunters(target)
		if not hunters then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Error while loading hunters.")
			return false
		end

		if #hunters == 0 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "This player is not being hunted.")
			return false
		end

		local targetName = HunterSystem:getNameByOwner(target) or "Unknown"
		local modalWindow = ModalWindow({
			title = "Hunters",
			message = fmt("Hunteds of %s", targetName)
		})
		HunterSystem:loadModalChunkHunters(modalWindow, hunters, 1, HunterSystem.chunkSize)
		modalWindow:sendToPlayer(player)
		return false
	end

	-- MARK: ALL
	if action == "all" then
		if not HunterSystem:loadAllHunters() then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Error while loading hunters.")
			return false
		end

		local hunters = HunterSystem:getAllValidHunters()
		if #hunters == 0 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "No hunters found.")
			return false
		end

		hunters = shuffle(hunters)
		local modalWindow = ModalWindow({
			title = "Hunters",
			message = "All hunters"
		})
		HunterSystem:loadModalChunkHunters(modalWindow, hunters, 1, HunterSystem.chunkSize)
		modalWindow:sendToPlayer(player)
		return false
	end

	-- MARK: DEFAULT
	player:popupFYI(fmt(
		"The commands are:\n\n%s add <player>,<amount>\n%s remove,<player>\n%s list,<player>\n%s all",
		repeat_values(HunterSystem.command, 4)))

	return false
end

talkAction:separator(" ")
talkAction:register()

local inFightTicks = configManager.getNumber(configKeys.PZ_LOCKED)

local creatureEvent = CreatureEvent("HunterSystemDeath")

function creatureEvent.onDeath(creature)
	local player = creature:getPlayer()
	if not player then return true end

	local timeNow = os.mtime()
	---@type table<integer, {killer: Player, damage: integer}>
	local killers = {}
	local totalDamage = 0
	for uid, cb in pairs(player:getDamageMap()) do
		local killer = Player(uid)
		if killer and killer ~= player and (timeNow - cb.ticks) <= inFightTicks then
			killers[#killers + 1] = {killer = killer, damage = cb.total}
			totalDamage = totalDamage + cb.total
		end
	end

	if #killers == 0 then return true end

	local hunters = HunterSystem:getHuntersByTarget(player:getGuid())
	if #hunters == 0 then return true end

	for _, hunter in ipairs(hunters) do
		if hunter.status == HunterStatus.ACTIVE and not hunter:isExpired() then
			local rewardGold = math.floor(hunter.rewardGold * totalDamage / player:getMaxHealth())
			for _, cb in ipairs(killers) do
				if cb.killer:canCarryMoney(rewardGold) then
					cb.killer:addMoney(rewardGold)
				else
					cb.killer:setBankBalance(cb.killer:getBankBalance() + rewardGold)
				end

				cb.killer:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
					fmt("You received %d gold coins for hunting %s.", rewardGold, player:getName()))
			end

			hunter.status = HunterStatus.FINISHED
			hunter.updatedAt = timeNow
			hunter.finishedAt = timeNow

			if HunterSystem.forceSave and not HunterSystem:saveHunters(hunter.owner) then
				debugPrint("[HuntedSystem] Error while saving hunters")
			end
		end
	end

	return true
end

creatureEvent:register()
