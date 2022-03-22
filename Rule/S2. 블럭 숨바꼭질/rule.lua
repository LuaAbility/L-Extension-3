local material = import("$.Material") -- 건들면 안됨!
local effect = import("$.potion.PotionEffectType") -- 건들면 안됨!

local startX = 169.5 -- 시작 시 텔레포트 할 좌표 / 월드보더의 기준 좌표
local startY = 65 -- 시작 시 텔레포트 할 좌표 / 월드보더의 기준 좌표
local startZ = 1323.5 -- 시작 시 텔레포트 할 좌표 / 월드보더의 기준 좌표

local hideTick = 300 -- 숨는 시간
local gameTime = hideTick + 300 -- 게임 진행 시간
local itemTick = 100 -- 철괴 지급 주기
local seekerCount = 5  -- 전체 인원의 (1 / seekerCount) 만큼 술래로 지정됨

local items = {  -- 시작 시 지급 아이템
	newInstance("$.inventory.ItemStack", {material.IRON_INGOT, 1})
}

function Init()
	plugin.getPlugin().gameManager:setVariable("gameCount", 0)
	
	plugin.skipInformationOption(true)
	plugin.raffleAbilityOption(false)
	plugin.skipYesOrNoOption(false)
	plugin.abilityAmountOption(1, false)
	plugin.abilityItemOption(true, material.IRON_INGOT)
	plugin.abilityCheckOption(true)
	plugin.cooldownMultiplyOption(1.0)
	plugin.setResourcePackPort(13356)
	plugin.getPlugin().useResourcePack = false
	game.setMaxHealth(20)

	plugin.registerRuleEvent("PlayerDeathEvent", "eliminate")
	plugin.registerRuleEvent("PlayerJoinEvent", "spectator")
end

function onEvent(funcID, event)
	if funcID == "eliminate" then eliminate(event) end
	if funcID == "spectator" then spectator(event) end
end

function onTimer()
	local count = plugin.getPlugin().gameManager:getVariable("gameCount")
	if count == nil then
		count = 0
		plugin.getPlugin().gameManager:setVariable("gameCount", count)
	end
	
	if count == 0 then
		shuffleRole()
		teleport()
		giveItem(true, items)
	end
	
	count = count + 1
	
	setFoodLevel()
	bossbar(count)
	
	if count < hideTick then hide()
	elseif (count - hideTick) % itemTick == 0 then 
		giveItem(false, items) 
	end
	if count >= gameTime then gameEnd() 
	else plugin.getPlugin().gameManager:setVariable("gameCount", count) end
end

function Reset()
	local bossbars = util.getTableFromList(plugin.getServer():getBossBars())
	for i = 1, #bossbars do
		plugin.getServer():getBossBar(bossbars[i]:getKey()):setVisible(false)
		plugin.getServer():removeBossBar(bossbars[i]:getKey())
	end
	
	local bossbar = plugin.getPlugin().gameManager:getVariable("timeBossbar")
	if bossbar then
		bossbar:setVisible(false)
		bossbar:removeAll()
	end
end

function spectator(event)
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		if players[i]:getPlayer():getName() == event:getPlayer():getName() then return 0 end
	end
	
	game.sendMessage(event:getPlayer(), "§6[§eLAbility§6] §e게임이 진행 중입니다. 관전 모드가 됩니다.")
	event:getPlayer():setGameMode(import("$.GameMode").SPECTATOR)
end

function shuffleRole()
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, 200 do
		local randomIndex = util.random(1, #players)
		local temp = players[randomIndex]
		players[randomIndex] = players[1]
		players[1] = temp
	end
	
	local count = (1 / seekerCount) * #players
	if count < 1 then count = 1 end
	for i = 1, count do
		game.addAbility(players[i], "LA-BH-SEEKER-HIDDEN")
		players[i]:getPlayer():sendTitle("§c술래", "§c모든 블럭 유저를 제거하세요!", 10, 80, 10)
	end
	
	for i = (count + 1), #players do
		game.addAbility(players[i], "LA-BH-HIDER-HIDDEN")
		players[i]:getPlayer():sendTitle("§a블럭", "§a제한시간동안 버티세요!", 10, 80, 10)
	end
end

function giveItem(clearInv, targetItem)
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		if clearInv then players[i]:getPlayer():getInventory():clear()
		else 
			game.sendActionBarMessage(players[i]:getPlayer(), "§6능력 사용에 필요한 아이템을 추가로 지급받습니다.")
			players[i]:getPlayer():playSound(players[i]:getPlayer():getLocation(), import("$.Sound").ENTITY_ITEM_PICKUP, 0.5, 1)
		end
		players[i]:getPlayer():getInventory():addItem(targetItem)
	end
end

function teleport()
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		players[i]:getPlayer():getInventory():clear()
		players[i]:getPlayer():teleport(newInstance("$.Location", { players[i]:getPlayer():getWorld(), startX, startY, startZ }) )
		players[i]:getPlayer():setGameMode(import("$.GameMode").ADVENTURE)
		players[i]:getPlayer():setHealth(players[i]:getPlayer():getAttribute(import("$.attribute.Attribute").GENERIC_MAX_HEALTH):getBaseValue())
	end
end

function setFoodLevel()
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		players[i]:getPlayer():setFoodLevel(14)
	end
end

function hide()
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		if game.hasAbility(players[i], "LA-BH-SEEKER-HIDDEN") then
			players[i]:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.SLOW, 10, 9}))
			players[i]:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.BLINDNESS, 40, 9}))
			players[i]:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.JUMP, 10, 250}))
		end
	end
end

function eliminate(event)
	if event:getEntity():getType():toString() == "PLAYER" then
		if game.getPlayer(event:getEntity()) ~= nil then
			game.eliminatePlayer(game.getPlayer(event:getEntity()))
			game.broadcastMessage("§4[§cLAbility§4] §c" .. event:getEntity():getName() .. "님이 탈락하셨습니다.")
			
			local blocks = remainBlocks()
			if #blocks < 1 then
				game.broadcastMessage("§6[§eLAbility§6] §e게임이 종료되었습니다.")
				game.broadcastMessage("§6[§eLAbility§6] §c술래 팀§e이 우승했습니다!")
				
				local players = util.getTableFromList(game.getAllPlayers())
				for i = 1, #players do
					players[i]:getPlayer():sendTitle("§c술래 팀 승리!", "§c모든 블럭 유저가 사망했습니다.", 10, 80, 10)
					players[i]:getPlayer():getWorld():playSound(players[i]:getPlayer():getLocation(), import("$.Sound").ENTITY_WITHER_AMBIENT, 0.5, 1)
				end
				
				game.endGame()
				return 0
			end
			
			local seekers = getSeekers()
			if #seekers < 1 then
				game.broadcastMessage("§6[§eLAbility§6] §e게임이 종료되었습니다.")
				game.broadcastMessage("§6[§eLAbility§6] §a블럭 팀§e이 우승했습니다!")
				
				local players = util.getTableFromList(game.getAllPlayers())
				for i = 1, #players do
					players[i]:getPlayer():sendTitle("§a블럭 팀 승리!", "§a게임 시간이 종료되었습니다.", 10, 80, 10)
					players[i]:getPlayer():getWorld():playSound(players[i]:getPlayer():getLocation(), import("$.Sound").UI_TOAST_CHALLENGE_COMPLETE, 0.5, 1)
				end
				
				game.endGame()
				return 0
			end
		end
	end
end

function gameEnd()
	local seekers = getSeekers()
	for i = 1, #seekers do
		seekers[i]:getPlayer():setHealth(0)
	end
end

function bossbar(count)
	local bossbar = plugin.getPlugin().gameManager:getVariable("timeBossbar")
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
	
	if count <= hideTick then
		local timedata = count / hideTick
		if timedata > 1 then timedata = 1 end
		bossbar:setProgress(1 - timedata)
		bossbar:setTitle("§6[§e숨는 시간§6] §c(술래 이동 불가)")
		bossbar:setColor(import("$.boss.BarColor").YELLOW)
	else
		local timedata = (count - hideTick) / (gameTime - hideTick)
		local remainTime = math.floor(((gameTime - count) / 20) + 0.5)
		local remainBlocks = #remainBlocks()
		if timedata > 1 then timedata = 1 end
		bossbar:setProgress(1 - timedata)
		bossbar:setTitle("§a남은 시간 : " .. remainTime .. "초 §6/ §b남은 인원 : " .. remainBlocks .. "명")
		bossbar:setColor(import("$.boss.BarColor").GREEN)
	end
end

function remainBlocks()
	local blocks = {}
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		if game.hasAbility(players[i], "LA-BH-HIDER-HIDDEN") then
			table.insert(blocks, players[i])
		end
	end
	
	return blocks
end

function getSeekers()
	local seekers = {}
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		if game.hasAbility(players[i], "LA-BH-SEEKER-HIDDEN") then
			table.insert(seekers, players[i])
		end
	end
	
	return seekers
end