local types = import("$.entity.EntityType")
local particle = import("$.Particle")
local circleDelay = 50

function Init(abilityData)
	plugin.registerEvent(abilityData, "비트 변경", "PlayerInteractEvent", 600)
	plugin.registerEvent(abilityData, "EX048-checkDamage", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "비트 변경" then useAbility(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "EX048-checkDamage" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then checkDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	local count = player:getVariable("EX048-abilityTime")
	if count == nil then 
		player:setVariable("EX048-abilityTime", 0) 
		player:setVariable("EX048-currentBar", 1) 
		
		local beat = {}
		for i = 1, 4 do
			local randomData = util.random(1, 4)
			if randomData == 1 then table.insert(beat, "강")
			elseif randomData == 4 then table.insert(beat, "중")
			else table.insert(beat, "약") end
		end
		
		player:setVariable("EX048-beat", beat) 
		count = 0
	end

	count = count + 1

	local str = ""
	local beat = player:getVariable("EX048-beat") 
	local bar = player:getVariable("EX048-currentBar") 
	
	if count % 12 == 0 then
		bar = bar + 1
		if bar > 4 then bar = 1 end
		player:setVariable("EX048-currentBar", bar) 
	end
	
	for i = 1, 4 do
		if bar == i then str = str .. "§6" .. beat[i]
		else str = str .. "§a" .. beat[i] end
		if i ~= 4 then str = str .. "§a - " end
	end
	
	game.sendActionBarMessage(player:getPlayer(), "EX048", str)
	
	player:setVariable("EX048-abilityTime", count) 
end

function useAbility(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					event:getPlayer():playSound(event:getPlayer(), import("$.Sound").ENTITY_EXPERIENCE_ORB_PICKUP, 0.5, 2)
					local beat = {}
					for i = 1, 4 do
						local randomData = util.random(1, 4)
						if randomData == 1 then table.insert(beat, "강")
						elseif randomData == 4 then table.insert(beat, "약")
						else table.insert(beat, "중") end
					end
					
					LAPlayer:setVariable("EX048-beat", beat) 
					LAPlayer:setVariable("EX048-currentBar", 1) 
				end
			end
		end
	end
end

function Reset(player, ability)
	game.sendActionBarMessageToAll("EX048", "")
end

function checkDamage(LAPlayer, event, ability, id)
	local damagee = event:getEntity()
	local damager = util.getRealDamager(event:getDamager())
	
	
	
	if damager ~= nil and damagee:getType():toString() == "PLAYER" then
		if game.checkCooldown(LAPlayer, game.getPlayer(damager), ability, id) then
			local beat = LAPlayer:getVariable("EX048-beat") 
			local bar = LAPlayer:getVariable("EX048-currentBar") 
			local result = beat[bar]
			
			if result == "강" then event:setDamage(event:getDamage() * 1.5)
			elseif result == "약" then event:setDamage(event:getDamage() * 0.5) end
		end
	end
end
