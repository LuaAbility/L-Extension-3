local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "EX046-damage", "PlayerInteractEvent", 0)
	plugin.registerEvent(abilityData, "EX046-cancelBreak", "BlockBreakEvent", 0)
	plugin.registerEvent(abilityData, "EX046-cancelDamage", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "EX046-damage" then damaged(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "EX046-cancelBreak" then cancelBreak(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "EX046-cancelDamage" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then cancelDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	local bPlayer = player:getPlayer()
	
	if bPlayer:isSneaking() then
		if player:getVariable("EX046-speed") == nil then
			player:setVariable("EX046-speed", bPlayer:getWalkSpeed())
		end
		
		if player:getVariable("EX046-block") == nil then
			local targetBlock = bPlayer:getWorld():getBlockAt(bPlayer:getLocation())
			local copyBlock = bPlayer:getWorld():getBlockAt(bPlayer:getLocation():add(0, -1, 0))
			
			if copyBlock:getType() ~= import("$.Material").AIR then
				player:setVariable("EX046-prevBlock", {targetBlock:getType(), targetBlock:getBlockData():clone()})
				
				targetBlock:setType(copyBlock:getType())
				player:setVariable("EX046-block", targetBlock)
				
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
			if util.random() <= 0.005 then
				local targetBlock = player:getVariable("EX046-block")
				bPlayer:getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, targetBlock:getLocation():add(0.5, 0, 0.5), 100, 0.25, 0.25, 0.25, 0.1)
			end
			
			bPlayer:setWalkSpeed(0)
			bPlayer:addPotionEffect(newInstance("$.potion.PotionEffect", {effect.JUMP, 3, 250}))
		end
	else
		Reset(player, ability)
	end
end

function Reset(player, ability)
	local targetBlock = player:getVariable("EX046-block")
	if targetBlock ~= nil then
		targetBlock:setType(player:getVariable("EX046-prevBlock")[1])
		targetBlock:setBlockData(player:getVariable("EX046-prevBlock")[2])
		player:removeVariable("EX046-block")
		player:removeVariable("EX046-prevBlock")
	end
	
	local speed = player:getVariable("EX046-speed")
	if speed ~= nil then
		player:getPlayer():setWalkSpeed(speed)
		player:removeVariable("EX046-speed")
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
		local targetBlock = LAPlayer:getVariable("EX046-block")
		if targetBlock ~= nil and targetBlock == event:getClickedBlock() then
			LAPlayer:getPlayer():getWorld():spawnParticle(import("$.Particle").CRIT, event:getClickedBlock():getLocation():add(0.5, 0, 0.5), 100, 0.25, 0.25, 0.25, 0.1)
			LAPlayer:getPlayer():getWorld():playSound(LAPlayer:getPlayer():getLocation(), import("$.Sound").ENTITY_PLAYER_ATTACK_CRIT, 0.5, 1)
			LAPlayer:getPlayer():damage(10, event:getPlayer())
		end
	end
end

function cancelBreak(LAPlayer, event, ability, id)
	local targetBlock = LAPlayer:getVariable("EX046-block")
	if targetBlock ~= nil and targetBlock == event:getBlock() then
		event:setCancelled(true)
	end
end

function cancelDamage(LAPlayer, event, ability, id)
	local damager = util.getRealDamager(event:getDamager())
	
	
	if damager ~= nil and game.checkCooldown(LAPlayer, game.getPlayer(damager), ability, id) then
		if LAPlayer:getVariable("EX046-block") ~= nil then
			event:setCancelled(true)
		end
	end
end
