local material = import("$.Material") -- 건들면 안됨!
local effect = import("$.potion.PotionEffectType")  -- 건들면 안됨!
local joinTick = 400 -- 입장 간격 (틱)

local startX = 169.5 -- 시작 시 텔레포트 할 좌표 / 월드보더의 기준 좌표
local startY = 65 -- 시작 시 텔레포트 할 좌표 / 월드보더의 기준 좌표
local startZ = 1323.5 -- 시작 시 텔레포트 할 좌표 / 월드보더의 기준 좌표

local startBorderSize = 50.0 -- 시작 시 월드 보더의 크기
local endBorderSize = 5.0 -- 마지막 월드 보더의 크기
local borderChangeSecond = 60 -- 월드보더의 크기가 변화하는 시간
	
local abilityItem = material.IRON_INGOT -- 능력 시전 아이템
local abilityItemName = "철괴" -- 능력 시전 아이템 이름
local startItem = {  -- 시작 시 지급 아이템
	newInstance("$.inventory.ItemStack", {material.IRON_INGOT, 64}),
	newInstance("$.inventory.ItemStack", {material.GOLD_INGOT, 64}),
	newInstance("$.inventory.ItemStack", {material.OAK_LOG, 10}),
	newInstance("$.inventory.ItemStack", {material.WATER_BUCKET, 1}),
	newInstance("$.inventory.ItemStack", {material.FISHING_ROD, 1}),
	newInstance("$.inventory.ItemStack", {material.BOW, 1}),
	newInstance("$.inventory.ItemStack", {material.ARROW, 64}),
	newInstance("$.inventory.ItemStack", {material.SCAFFOLDING, 20}),
	newInstance("$.inventory.ItemStack", {material.IRON_SWORD, 1}),
	newInstance("$.inventory.ItemStack", {material.IRON_SWORD, 1}),
	newInstance("$.inventory.ItemStack", {material.IRON_SWORD, 1})
}

local startEquip = {  -- 시작 시 지급 아이템
	newInstance("$.inventory.ItemStack", {material.CHAINMAIL_BOOTS, 1}),
	newInstance("$.inventory.ItemStack", {material.CHAINMAIL_LEGGINGS, 1}),
	newInstance("$.inventory.ItemStack", {material.CHAINMAIL_CHESTPLATE, 1}),
	newInstance("$.inventory.ItemStack", {material.CHAINMAIL_HELMET, 1})
}

function Init()
	math.randomseed(os.time()) -- 건들면 안됨!
	
	plugin.getPlugin().gameManager:setVariable("gameCount", 0)
	plugin.getPlugin().gameManager:setVariable("isGodMode", false)
	plugin.getPlugin().gameManager:setVariable("worldBorder", nil)
	
	plugin.skipInformationOption(false) -- 모든 게임 시작과정을 생략하고 게임을 시작할 지 정합니다.
	plugin.raffleAbilityOption(true) -- 시작 시 능력을 추첨할 지 결정합니다.
	plugin.skipYesOrNoOption(false) -- 플레이어에게 능력 재설정을 가능하게 할 것인지 정합니다. true : 능력 재설정 불가 / false : 능력 재설정 가능
	plugin.abilityAmountOption(1, false) -- 능력의 추첨 옵션입니다. 숫자로 능력의 추첨 개수를 정하고, true/false로 다른 플레이어와 능력이 중복될 수 있는지를 정합니다. 같은 플레이어에게는 중복된 능력이 적용되지 않습니다.
	plugin.abilityItemOption(true, abilityItem, abilityItemName) -- 능력 발동 아이템 옵션입니다. true/false로 모든 능력의 발동 아이템을 통일 할 것인지 정하고, Material을 통해 통일할 아이템을 설정합니다.
	plugin.abilityCheckOption(true) -- 능력 확인 옵션입니다. 플레이어가 자신의 능력을 확인할 수 있는 지 정합니다.
	plugin.cooldownMultiplyOption(1.0) -- 능력 쿨타임 옵션입니다. 해당 값만큼 쿨타임 값에 곱해져 적용됩니다. (예: 0.5일 경우 쿨타임이 기본 쿨타임의 50%, 2.0일 경우 쿨타임이 기본 쿨타임의 200%)
	plugin.setResourcePackPort(13356)
	plugin.getPlugin().useResourcePack = true
	
	-- 실질적 무능력 능력
	plugin.banAbilityID("LA-SCP-451")
	plugin.banAbilityID("LA-SCP-___")
	plugin.banAbilityID("LA-MW-036")
	plugin.banAbilityID("LA-MW-019")
	plugin.banAbilityID("LA-MW-014")
	plugin.banAbilityID("LA-MW-008")
	plugin.banAbilityID("LA-MW-006")
	plugin.banAbilityID("LA-MW-004")
	plugin.banAbilityID("LA-MW-001")
	plugin.banAbilityID("LA-HS-015")
	plugin.banAbilityID("LA-HS-001")
	plugin.banAbilityID("LA-EX-034")
	plugin.banAbilityID("LA-EX-032")
	plugin.banAbilityID("LA-EX-028")
	plugin.banAbilityID("LA-EX-023")
	
	-- 부적합 능력
	plugin.banAbilityID("LA-SCP-507")
	plugin.banAbilityID("LA-HS-020")
	plugin.banAbilityID("LA-HS-018")
	plugin.banAbilityID("LA-HS-014")
	plugin.banAbilityID("LA-HS-002")
	plugin.banAbilityID("LA-EX-029")
	plugin.banAbilityID("LA-EX-013")
	plugin.banAbilityID("LA-EX-008")

	plugin.registerRuleEvent("PlayerDeathEvent", "eliminate")
	plugin.registerRuleEvent("PlayerJoinEvent", "spectator")
	plugin.registerRuleEvent("BlockPlaceEvent", "cancelPlace")
	plugin.registerRuleEvent("EntityDamageEvent", "godMode")
	plugin.registerRuleEvent("PlayerMoveEvent", "cancelMove")
	plugin.registerRuleEvent("PlayerEliminateEvent", "removeQueue")
end

function onEvent(funcID, event)
	if funcID == "eliminate" then eliminate(event) end
	if funcID == "spectator" then spectator(event) end
	if funcID == "cancelPlace" then cancelPlace(event) end
	if funcID == "godMode" then godMode(event) end
	if funcID == "cancelMove" then cancelMove(event) end
	if funcID == "removeQueue" then removeQueue(event) end
end

function spectator(event)
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		if players[i]:getPlayer():getName() == event:getPlayer():getName() then return 0 end
	end
	
	game.sendMessage(event:getPlayer(), "§6[§eLAbility§6] §e게임이 진행 중입니다. 관전 모드가 됩니다.")
	event:getPlayer():setGameMode(import("$.GameMode").SPECTATOR)
end

function cancelPlace(event)
	local block = event:getBlockPlaced()
	if block:getLocation():getY() > 100 then 
		event:setCancelled(true)
		game.sendMessage(event:getPlayer(), "§4[§cLAbility§4] §c너무 높이 설치하려 합니다!")
	end	
end

function cancelMove(event)
	if event:getTo():getY() > 100 then 
		local newTo = event:getTo()
		newTo:setY(98)
		event:setTo(newTo)
		game.sendMessage(event:getPlayer(), "§4[§cLAbility§4] §c너무 높이 올라가려 합니다!")
	end	
end

function godMode(event)
	if event:getEntity():getType():toString() == "PLAYER" then
		local player = game.getPlayer(event:getEntity())
		if player ~= nil and player:getVariable("godMode") then
			event:setCancelled(true)
		end
	end
end

function onTimer()
	local count = plugin.getPlugin().gameManager:getVariable("gameCount")
	if count == nil then
		plugin.getPlugin().gameManager:setVariable("gameCount", 0)
		plugin.getPlugin().gameManager:setVariable("worldBorder", nil)
		count = 0
	end
	
	if count == 0 then
		teleport()
		setWorldBorder()
		createQueue()
		join()
	end
	
	
	local playerQueue = plugin.getPlugin().gameManager:getVariable("playerQueue")
	if #playerQueue > 0 and count % joinTick == 0 then
		join()
		count = 0
	end
	
	if #playerQueue == 0 and count == 0 then
		reductWorldBorder()
	end
	
	setFoodLevel()
	bossbar(count)
	count = count + 2
	plugin.getPlugin().gameManager:setVariable("gameCount", count)
end

function teleport()
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		players[i]:getPlayer():getInventory():clear()
		players[i]:getPlayer():setHealth(players[i]:getPlayer():getAttribute(import("$.attribute.Attribute").GENERIC_MAX_HEALTH):getBaseValue())
		players[i]:getPlayer():teleport(newInstance("$.Location", { players[i]:getPlayer():getWorld(), startX, startY + 20, startZ }) )
		players[i]:getPlayer():setGameMode(import("$.GameMode").SPECTATOR)
		players[i]:setVariable("abilityLock", true)
	end
end

function createQueue()
	plugin.getPlugin().gameManager:setVariable("playerQueue", { })
	
	local players = util.getTableFromList(game.getPlayers())
	local playerQueue = plugin.getPlugin().gameManager:getVariable("playerQueue")
	
	local SRank = {}
	local ARank = {}
	local BRank = {}
	local CRank = {}
	local EtcRank = {}
	
	for i = 1, #players do
		local abilities = players[i]:getAbility()
		if players[i]:getAbility():size() > 0 then
			local rank = players[i]:getAbility():get(0).abilityRank
			
			if rank == "S" then table.insert(SRank, players[i])
			elseif rank == "A" then table.insert(ARank, players[i])
			elseif rank == "B" then table.insert(BRank, players[i])
			elseif rank == "C" then table.insert(CRank, players[i])
			else table.insert(EtcRank, players[i]) end
		else
			table.insert(EtcRank, players[i])
		end
	end
	
	if #SRank > 1 then
		for i = 1, 100 do
			local randomIndex = util.random(1, #SRank)
			local temp = SRank[randomIndex]
			SRank[randomIndex] = SRank[1]
			SRank[1] = temp
		end
		
		for i = 1, #SRank do
			table.insert(playerQueue, SRank[i])
		end
	elseif #SRank == 1 then 
		table.insert(playerQueue, SRank[1])
	end
	
	if #ARank > 1 then
		for i = 1, 100 do
			local randomIndex = util.random(1, #ARank)
			local temp = ARank[randomIndex]
			ARank[randomIndex] = ARank[1]
			ARank[1] = temp
		end
		
		for i = 1, #ARank do
			table.insert(playerQueue, ARank[i])
		end
	elseif #ARank == 1 then 
		table.insert(playerQueue, ARank[1])
	end
	
	if #BRank > 1 then
		for i = 1, 100 do
			local randomIndex = util.random(1, #BRank)
			local temp = BRank[randomIndex]
			BRank[randomIndex] = BRank[1]
			BRank[1] = temp
		end
		
		for i = 1, #BRank do
			table.insert(playerQueue, BRank[i])
		end
	elseif #BRank == 1 then 
		table.insert(playerQueue, BRank[1])
	end
	
	if #CRank > 1 then
		for i = 1, 100 do
			local randomIndex = util.random(1, #CRank)
			local temp = CRank[randomIndex]
			CRank[randomIndex] = CRank[1]
			CRank[1] = temp
		end
		
		for i = 1, #CRank do
			table.insert(playerQueue, CRank[i])
		end
	elseif #CRank == 1 then 
		table.insert(playerQueue, CRank[1])
	end
	
	if #EtcRank > 1 then
		for i = 1, 100 do
			local randomIndex = util.random(1, #EtcRank)
			local temp = EtcRank[randomIndex]
			EtcRank[randomIndex] = EtcRank[1]
			EtcRank[1] = temp
		end
		
		for i = 1, #EtcRank do
			table.insert(playerQueue, EtcRank[i])
		end
	elseif #EtcRank == 1 then 
		table.insert(playerQueue, EtcRank[1])
	end
end

function join()
	local playerQueue = plugin.getPlugin().gameManager:getVariable("playerQueue")
	local joinPlayer = playerQueue[1]
	local loc = newInstance("$.Location", { joinPlayer:getPlayer():getWorld(), startX, startY, startZ })
	
	joinPlayer:setVariable("abilityLock", false)
	joinPlayer:setVariable("godMode", true)
	
	giveItem(joinPlayer:getPlayer(), true)
	
	joinPlayer:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.GLOWING, 200, 9}))
	joinPlayer:getPlayer():setGameMode(import("$.GameMode").SURVIVAL)
	joinPlayer:getPlayer():teleport(loc)
	
	local title = "§6[§eLAbility§6] §e"
	
	local abilities = playerQueue[1]:getAbility()
	if playerQueue[1]:getAbility():size() > 0 then
		local rank = playerQueue[1]:getAbility():get(0).abilityRank
		if rank == "S" then title = title .. "S"
		elseif rank == "A" then title = title .. "A"
		elseif rank == "B" then title = title .. "B"
		elseif rank == "C" then title = title .. "C"
		else title = title .. "???" end
	else
		title = title .. "???"
	end
	
	title = title .. "랭크 플레이어 §6" .. playerQueue[1]:getPlayer():getName() .. "§e님이 게임에 참여하셨습니다."
	game.broadcastMessage(title)
	
	util.runLater(function()
		joinPlayer:getPlayer():setHealth(joinPlayer:getPlayer():getAttribute(import("$.attribute.Attribute").GENERIC_MAX_HEALTH):getBaseValue())
	end, 2)
	
	util.runLater(function()
		joinPlayer:setVariable("godMode", false)
	end, 100)
	
	table.remove(playerQueue, 1)
end

function setFoodLevel()
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		players[i]:getPlayer():setFoodLevel(20)
		if players[i]:getPlayer():getSaturatedRegenRate() < 1000 then players[i]:getPlayer():setSaturatedRegenRate(10) players[i]:getPlayer():setSaturation(1) end
	end
end

function giveItem(player, clearInv)
	if game.getPlayer(player).isSurvive then 
		game.sendMessage(player, "§2[§aLAbility§2] §a기본 아이템을 지급받습니다.")
		if clearInv then player:getInventory():clear() end -- 인벤토리 초기화 
		player:getInventory():addItem(startItem) -- 아이템 지급
		player:getInventory():setArmorContents(startEquip)
	end
end

function eliminate(event)
	if event:getEntity():getType():toString() == "PLAYER" then
		local player = game.getPlayer(event:getEntity())
		if player ~= nil then
			game.eliminatePlayer(player)
			event:getEntity():getInventory():clear()
			event:getEntity():getWorld():strikeLightningEffect(event:getEntity():getLocation())
			game.broadcastMessage("§4[§cLAbility§4] §c" .. event:getEntity():getName() .. "님이 탈락하셨습니다.")
			game.sendMessage(event:getEntity(), "§4[§cLAbility§4] §c사망으로 인해 탈락하셨습니다.")
			
			local players = util.getTableFromList(game.getPlayers())
			if #players == 1 then
				game.broadcastMessage("§6[§eLAbility§6] §e게임이 종료되었습니다.")
				game.broadcastMessage("§6[§eLAbility§6] §e" .. players[1]:getPlayer():getName() .. "님이 우승하셨습니다!")
				game.endGame()
			elseif #players < 1 then
				game.broadcastMessage("§6[§eLAbility§6] §e게임이 종료되었습니다.")
				game.broadcastMessage("§6[§eLAbility§6] §e우승자가 없습니다.")
				game.endGame()
			end
		end
	end
end

function removeQueue(event)
	local player = event:getPlayer()
	local playerQueue = plugin.getPlugin().gameManager:getVariable("playerQueue")
	local playerIndex = 0
	for i = 1, #playerQueue do
		if playerQueue[i]:getPlayer():getName() == player:getPlayer():getName() then
			playerIndex = i
		end
	end
	
	if playerIndex > 0 then
		table.remove(playerQueue, playerIndex)
	end
end

function bossbar(count)
	local bossbar = plugin.getPlugin().gameManager:getVariable("timeBossbar")
	local playerQueue = plugin.getPlugin().gameManager:getVariable("playerQueue")
	if playerQueue then
		if not bossbar then
			local bossbarKey = newInstance("$.NamespacedKey", {plugin.getPlugin(), "timeBossbar" })
			local timeBossbar = plugin.getServer():createBossBar(bossbarKey, "", import("$.boss.BarColor").WHITE, import("$.boss.BarStyle").SEGMENTED_20, { } )
			local players = util.getTableFromList(game.getPlayers())
			for i = 1, #players do
				timeBossbar:addPlayer(players[i]:getPlayer())
			end
			
			plugin.getPlugin().gameManager:setVariable("timeBossbar", timeBossbar)
			bossbar = timeBossbar
		end
		
		if #playerQueue > 0 then
			local timedata = count / joinTick
			if timedata > 1 then timedata = 1 end
			bossbar:setProgress(1 - timedata)
			bossbar:setColor(import("$.boss.BarColor").GREEN)
			
			local title = "§e다음 플레이어 랭크 : "
			
			local abilities = playerQueue[1]:getAbility()
			if playerQueue[1]:getAbility():size() > 0 then
				local rank = playerQueue[1]:getAbility():get(0).abilityRank
				if rank == "S" then title = title .. "S"
				elseif rank == "A" then title = title .. "A"
				elseif rank == "B" then title = title .. "B"
				elseif rank == "C" then title = title .. "C"
				else title = title .. "???" end
			else
				title = title .. "???"
			end
			
			bossbar:setTitle(title)
			game.sendActionBarMessage(playerQueue[1]:getPlayer(), "§a다음 순서입니다! 준비하세요...")
		elseif count <= borderChangeSecond * 20 then
			local timedata = count / (borderChangeSecond * 20)
			if timedata > 1 then timedata = 1 end
			local currentSize = startBorderSize - math.floor((startBorderSize - endBorderSize) * (timedata) + 0.5)
			local str = " §c현재 월드 크기 : " .. currentSize .. "칸"
			
			bossbar:setProgress(1 - timedata)
			bossbar:setTitle("§4[§c월드 축소§4]" .. str)
			bossbar:setColor(import("$.boss.BarColor").RED)
		else
			bossbar:setProgress(1)
			bossbar:setTitle("§8[§7월드 축소 종료§8]")
			bossbar:setColor(import("$.boss.BarColor").WHITE)
		end
	end
end

function setWorldBorder()
	local player = util.getTableFromList(game.getPlayers())[1]:getPlayer()
	local border = player:getWorld():getWorldBorder()
	border:setCenter(startX, startZ)
	border:setSize(startBorderSize)
	
	border = plugin.getPlugin().gameManager:setVariable("worldBorder", border)
end

function reductWorldBorder()
	local border = plugin.getPlugin().gameManager:getVariable("worldBorder")
	if border ~= nil then
		border:setSize(endBorderSize, borderChangeSecond)
		border:setDamageAmount(0.1)
		border:setDamageBuffer(1)
		game.broadcastMessage("§4[§cLAbility§4] §c지금부터 월드의 크기가 작아집니다!")
		game.broadcastMessage("§4[§cLAbility§4] §c크기는 ".. borderChangeSecond .. "초 동안 축소됩니다.")
		game.broadcastMessage("§4[§cLAbility§4] §c기준 좌표 - X : " .. startX .. " / Z : " .. startZ)
		game.broadcastMessage("§4[§cLAbility§4] §c크기 - " .. endBorderSize .. "칸")
	end
end

function Reset()
	game.resetWorld()
	local border = plugin.getPlugin().gameManager:getVariable("worldBorder")
	if border ~= nil then
		border:setSize(9999999)
		border:setCenter(startX, startZ)
	end

	local bossbars = util.getTableFromList(plugin.getServer():getBossBars())
	for i = 1, #bossbars do
		plugin.getServer():getBossBar(bossbars[i]:getKey()):setVisible(false)
		plugin.getServer():removeBossBar(bossbars[i]:getKey())
	end
end