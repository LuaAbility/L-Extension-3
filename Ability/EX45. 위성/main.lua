local types = import("$.entity.EntityType")
local particle = import("$.Particle")
local circleDelay = 50

function Init(abilityData)
	plugin.registerEvent(abilityData, "고속 공전", "PlayerInteractEvent", 600)
	plugin.registerEvent(abilityData, "EX045-cancelDamage", "EntityDamageEvent", 0)
	plugin.registerEvent(abilityData, "EX045-getMove", "PlayerMoveEvent", 0)
	plugin.registerEvent(abilityData, "EX045-getVelocity", "PlayerVelocityEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "고속 공전" then useAbility(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "EX045-cancelDamage" then cancelDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "EX045-getMove" then getMove(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "EX045-getVelocity" then getVelocity(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("EX045-abilityTime") == nil then 
		player:setVariable("EX045-abilityTime", 0) 
		player:setVariable("EX045-fastRevolution", 0) 
		player:setVariable("EX045-move", nil) 
		
		local satellite = player:getPlayer():getWorld():spawnEntity(player:getPlayer():getLocation(), types.ARMOR_STAND)
		satellite:setGravity(false)
		satellite:setVisible(false)
		
		player:setVariable("EX045-satellite", satellite) 
	else
		local fastRevolution = player:getVariable("EX045-fastRevolution")
		local timeCount = player:getVariable("EX045-abilityTime")
		
		if fastRevolution > 0 then
			fastRevolution = fastRevolution - 2
			timeCount = timeCount + 8
			player:setVariable("EX045-fastRevolution", fastRevolution)
		end
		
		timeCount = timeCount + 2
		circleEffect(player, timeCount % circleDelay)
		player:setVariable("EX045-abilityTime", timeCount)
		player:setVariable("EX045-move", newInstance("$.util.Vector", {0, 0, 0}))
	end
end

function Reset(player, ability)
	local satellite = player:getVariable("EX045-satellite")
	if satellite ~= nil then
		satellite:remove()
	end
end

function cancelDamage(LAPlayer, event, ability, id)
	local satellite = LAPlayer:getVariable("EX045-satellite")
	if satellite ~= nil and event:getEntity() == satellite then
		event:setCancelled(true)
		event:getEntity():getWorld():playSound(event:getEntity():getLocation(), import("$.Sound").BLOCK_ANVIL_PLACE, 0.5, 2)
	end
end

function getMove(LAPlayer, event, ability, id)
	if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
		LAPlayer:setVariable("EX045-move", event:getTo():toVector():subtract(event:getFrom():toVector()):multiply(newInstance("$.util.Vector", {3, 0, 3}))) 
	end
end

function getVelocity(LAPlayer, event, ability, id)
	if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
		LAPlayer:setVariable("EX045-move", event:getVelocity()) 
	end
end

function useAbility(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					LAPlayer:setVariable("EX045-fastRevolution", 60) 
				end
			end
		end
	end
end

function circleEffect(lap, count)
	local satellite = lap:getVariable("EX045-satellite")
    local location = lap:getPlayer():getLocation():clone()
	
	local move = lap:getVariable("EX045-move")
    if move ~= nil then 
		location:add(move)
	end
	
    local angle = 2 * math.pi * count / circleDelay
    local x = math.cos(angle)
    local z = math.sin(angle)
    location:add(x, 0, z)
	satellite:teleport(location)
	
	satellite:getWorld():spawnParticle(particle.REDSTONE, satellite:getLocation():add(0, 1, 0), 20, 0.25, 0.25, 0.25, 0.01, newInstance("$.Particle$DustOptions", { import("$.Color"):fromRGB(051, 051, 051), 1 }))
	satellite:getWorld():spawnParticle(particle.REDSTONE, satellite:getLocation():add(0, 1, 0), 15, 0.25, 0.25, 0.25, 0.01, newInstance("$.Particle$DustOptions", { import("$.Color"):fromRGB(102, 102, 102), 1 }))
	satellite:getWorld():spawnParticle(particle.REDSTONE, satellite:getLocation():add(0, 1, 0), 10, 0.25, 0.25, 0.25, 0.01, newInstance("$.Particle$DustOptions", { import("$.Color"):fromRGB(000, 000, 000), 1 }))
	satellite:getWorld():spawnParticle(particle.REDSTONE, satellite:getLocation():add(0, 1, 0), 05, 0.25, 0.25, 0.25, 0.01, newInstance("$.Particle$DustOptions", { import("$.Color"):fromRGB(153, 153, 153), 1 }))
	satellite:getWorld():spawnParticle(particle.REDSTONE, satellite:getLocation():add(0, 1, 0), 01, 0.25, 0.25, 0.25, 0.01, newInstance("$.Particle$DustOptions", { import("$.Color"):fromRGB(204, 204, 204), 1 }))
end
