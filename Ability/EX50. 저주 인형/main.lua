local types = import("$.entity.EntityType")
local material = import("$.Material")

function Init(abilityData)
	plugin.registerEvent(abilityData, "인형 소환", "SignChangeEvent", 1200)
	plugin.registerEvent(abilityData, "EX050-cancelDamage", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "인형 소환" then summonDoll(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "EX050-cancelDamage" then cancelDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	local count = player:getVariable("EX050-abilityTime")
	if count == nil then 
		player:setVariable("EX050-abilityTime", 0) 
		player:setVariable("EX050-voodooDoll", nil) 
		player:setVariable("EX050-targetPlayer", "") 
		
		count = 0
	end
	
	if count > 0 then
		count = count - 1
		if count <= 0 then
			Reset(player, ability)
		end
		player:setVariable("EX050-abilityTime", count) 
	end
end

function Reset(player, ability)
	local voodooDoll = player:getVariable("EX050-voodooDoll")
	if voodooDoll ~= nil then
		voodooDoll:remove()
		voodooDoll:getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, voodooDoll:getLocation():add(0, 1, 0), 400, 0.4, 1, 0.4, 0.05)
	end
end

function cancelDamage(LAPlayer, event, ability, id)
	local voodooDoll = LAPlayer:getVariable("EX050-voodooDoll")
	if voodooDoll ~= nil and event:getEntity() == voodooDoll then
		local players = util.getTableFromList(game.getTeamManager():getOpponentTeam(LAPlayer, false))
		local playerName = LAPlayer:getVariable("EX050-targetPlayer") 
		
		for i = 1, #players do
			if players[i]:getPlayer():getName() == playerName then	
				players[i]:getPlayer():damage(event:getDamage() * 0.5, LAPlayer:getPlayer())
				voodooDoll:getWorld():spawnParticle(import("$.Particle").CRIT, voodooDoll:getLocation():add(0, 1, 0), 30, 0.25, 0.7, 0.25, 0.1)
				voodooDoll:getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, voodooDoll:getLocation():add(0, 1, 0), 50, 0.25, 0.7, 0.25, 0.05)
				voodooDoll:getWorld():playSound(voodooDoll:getLocation(), import("$.Sound").ENTITY_PLAYER_ATTACK_CRIT, 0.5, 1)
			end
		end
		event:setCancelled(true)
	end
end

function summonDoll(LAPlayer, event, ability, id)
	if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
		local playerName = event:getLine(0)
		local players = util.getTableFromList(game.getTeamManager():getOpponentTeam(LAPlayer, false))
		for i = 1, #players do
			if players[i]:getPlayer():getName() == playerName then
				if game.targetPlayer(LAPlayer, players[i]) then
					local targetPlayer = players[i]
					game.sendMessage(targetPlayer:getPlayer(), "§4[§c저주 인형§4] §c당신의 저주인형이 생성 되었습니다.")
					event:getBlock():setType(material.AIR)
					
					local loc = event:getBlock():getLocation():add(0.5, 0, 0.5)
					loc:setYaw(LAPlayer:getPlayer():getLocation():getYaw() - 180)
					
					local armorStand = targetPlayer:getPlayer():getLocation():getWorld():spawnEntity(loc, types.ARMOR_STAND)
					local item = newInstance("$.inventory.ItemStack", {material.PLAYER_HEAD})
					local sm = item:getItemMeta()
					sm:setOwner(targetPlayer:getPlayer():getName())
					item:setItemMeta(sm)
				
					armorStand:getEquipment():setHelmet(item)
					armorStand:setCustomName(targetPlayer:getPlayer():getName())
					
					LAPlayer:setVariable("EX050-voodooDoll", armorStand) 
					LAPlayer:setVariable("EX050-targetPlayer", targetPlayer:getPlayer():getName()) 
					LAPlayer:setVariable("EX050-abilityTime", 100) 
					return 0 
				else
					ability:resetCooldown(id)
					return 0 
				end
			end
		end
		game.sendMessage(event:getPlayer(), "§8[§7저주 인형§8] §7해당 플레이어가 존재하지 않거나 탈락한 상태입니다.")
		ability:resetCooldown(id)
	end
end