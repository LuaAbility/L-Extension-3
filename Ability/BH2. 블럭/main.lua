local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "BH002-damage", "PlayerInteractEvent", 0)
	plugin.registerEvent(abilityData, "BH002-cancelBreak", "BlockBreakEvent", 0)
	plugin.registerEvent(abilityData, "BH002-cancelDamage", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "BH002-damage" then damaged(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "BH002-cancelBreak" then cancelBreak(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "BH002-cancelDamage" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then cancelDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	local bPlayer = player:getPlayer()
	
	if bPlayer:isSneaking() then
		if player:getVariable("BH002-speed") == nil then
			player:setVariable("BH002-speed", bPlayer:getWalkSpeed())
		end
		
		if player:getVariable("BH002-block") == nil then
			local targetBlock = bPlayer:getWorld():getBlockAt(bPlayer:getLocation())
			local copyBlock = bPlayer:getWorld():getBlockAt(bPlayer:getLocation():add(0, -1, 0))
			
			if copyBlock:getType() ~= import("$.Material").AIR then
				player:setVariable("BH002-prevBlock", {targetBlock:getType(), targetBlock:getBlockData():clone()})
				
				targetBlock:setType(copyBlock:getType())
				player:setVariable("BH002-block", targetBlock)
				
				local players = util.getTableFromList(game.getAllPlayers())
				for i = 1, #players do
					if players[i] ~= game.getPlayer(bPlayer) then
						players[i]:getPlayer():hidePlayer(plugin.getPlugin(), bPlayer)
					end
				end
				
				local telLoc = targetBlock:getLocation():clone():add(0.5, 1, 0.5)
				telLoc:setPitch(bPlayer:getLocation():getPitch())
				telLoc:setYaw(bPlayer:getLocation():getYaw())
				
				bPlayer:teleport(telLoc)
			end
		else
			bPlayer:setFallDistance(0)
			bPlayer:setWalkSpeed(0)
			bPlayer:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.JUMP, 3, 250}))
		end
	else
		Reset(player, ability)
	end
	
	
	if player:getVariable("BH002-abilityTime") == nil then player:setVariable("BH002-abilityTime", 0) end
	local count = player:getVariable("BH002-abilityTime")
	if count > 0 then 
		if count % 4 == 0 then randomDir(player) end
		if count <= 0 then game.sendMessage(player:getPlayer(), "§2[§a블럭§2] §a능력 시전 시간이 종료되었습니다. (술래 혼란)") end
	end
	
	count = count - 2 
	player:setVariable("BH002-abilityTime", count)
end

function Reset(player, ability)
	local targetBlock = player:getVariable("BH002-block")
	if targetBlock ~= nil then
		targetBlock:setType(player:getVariable("BH002-prevBlock")[1])
		targetBlock:setBlockData(player:getVariable("BH002-prevBlock")[2])
		player:removeVariable("BH002-block")
		player:removeVariable("BH002-prevBlock")
	end
	
	local speed = player:getVariable("BH002-speed")
	if speed ~= nil then
		player:getPlayer():setWalkSpeed(speed)
		player:removeVariable("BH002-speed")
	end
	
	local players = util.getTableFromList(game.getAllPlayers())
	for i = 1, #players do
		if players[i] ~= game.getPlayer(player:getPlayer()) then
			players[i]:getPlayer():showPlayer(plugin.getPlugin(), player:getPlayer())
		end
	end
end

function damaged(LAPlayer, event, ability, id)
	if event:getAction():toString() == "LEFT_CLICK_BLOCK" then
		local targetBlock = LAPlayer:getVariable("BH002-block")
		if targetBlock ~= nil and targetBlock == event:getClickedBlock() then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then return 0 end
			LAPlayer:getPlayer():getWorld():spawnParticle(import("$.Particle").CRIT, event:getClickedBlock():getLocation():add(0.5, 0, 0.5), 300, 0.4, 0.6, 0.4, 0.1)
			LAPlayer:getPlayer():getWorld():playSound(LAPlayer:getPlayer():getLocation(), import("$.Sound").ENTITY_PLAYER_ATTACK_CRIT, 0.5, 1)
			LAPlayer:getPlayer():damage(8, event:getPlayer())
		end
	elseif event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					local count = LAPlayer:getVariable("BH002-abilityTime")
					if count and count <= 0 then 
						game.sendMessage(event:getPlayer(), "§2[§a블럭§2] §a능력을 사용했습니다. (술래 혼란)")
						LAPlayer:setVariable("BH002-abilityTime", 100) 
						local itemStack = { newInstance("$.inventory.ItemStack", {event:getMaterial(), 1}) }
						event:getPlayer():getInventory():removeItem(itemStack)
					else
					game.sendMessage(event:getPlayer(), "§4[§c블럭§4] §c능력이 시전 중입니다.")
					end
				end
			end
		end
	end
end

function cancelBreak(LAPlayer, event, ability, id)
	local targetBlock = LAPlayer:getVariable("BH002-block")
	if targetBlock ~= nil and targetBlock == event:getBlock() then
		event:setCancelled(true)
	end
end

function cancelDamage(LAPlayer, event, ability, id)
	local damager = event:getDamager()
	if event:getCause():toString() == "PROJECTILE" then damager = event:getDamager():getShooter() end
	
	if not util.hasClass(damager, "org.bukkit.projectiles.BlockProjectileSource") and game.checkCooldown(LAPlayer, game.getPlayer(damager), ability, id) then
		event:setDamage(0)
	end
end

function randomDir(player)
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		if game.targetPlayer(player, players[i], false) and game.hasAbility(players[i], "LA-BH-SEEKER-HIDDEN") then
			local loc = players[i]:getPlayer():getLocation()
			loc:setPitch(util.random(-90, 90))
			loc:setYaw(util.random(0, 360))
			players[i]:getPlayer():teleport(loc)
			players[i]:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, players[i]:getPlayer():getLocation():add(0,1,0), 100, 0.5, 1, 0.5, 0.05)
			players[i]:getPlayer():getWorld():playSound(players[i]:getPlayer():getLocation(), import("$.Sound").ENTITY_ITEM_PICKUP, 0.25, 1)
			game.sendActionBarMessage(players[i]:getPlayer(), "§c" .. player:getPlayer():getName() .. "이(가) 혼란을 시전했습니다!")
		end
	end
end