local types = import("$.entity.EntityType")
local attribute = import("$.attribute.Attribute")
local material = import("$.Material")

function Init(abilityData)
	plugin.registerEvent(abilityData, "보디가드 호출", "PlayerInteractEvent", 400)
	plugin.registerEvent(abilityData, "EX044-cancelDamage", "EntityDamageEvent", 0)
	plugin.registerEvent(abilityData, "EX044-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "보디가드 호출" then useAbility(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "EX044-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "EX044-cancelDamage" then cancelDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("EX044-guard") == nil then 
		local guard = player:getPlayer():getWorld():spawnEntity(player:getPlayer():getLocation(), types.ZOMBIE)
		guard:getAttribute(attribute.GENERIC_MOVEMENT_SPEED):setBaseValue(0.4)
		guard:setCustomName("§b" .. player:getPlayer():getName() .. "의 보디가드")
		
		local helmet = newInstance("$.inventory.ItemStack", {material.DIAMOND_HELMET})
		local hMeta = helmet:getItemMeta()
		hMeta:setUnbreakable(true)
		helmet:setItemMeta(hMeta)
		guard:getEquipment():setHelmet(helmet)
		
		player:setVariable("EX044-guard", guard) 
	end	
end

function Reset(player, ability)
	local guard = player:getVariable("EX044-guard")
	if guard ~= nil then
		guard:setHealth(0)
	end
end

function cancelDamage(LAPlayer, event, ability, id)
	local guard = LAPlayer:getVariable("EX044-guard")
	if guard ~= nil and event:getEntity() == guard then
		event:setDamage(0)
	end
end

function useAbility(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					local target = LAPlayer:getVariable("EX044-guard")
					target:getWorld():spawnParticle(import("$.Particle").PORTAL, target:getLocation():add(0,1,0), 1000, 0.1, 0.1, 0.1)
					target:getWorld():playSound(target:getLocation(), import("$.Sound").ITEM_CHORUS_FRUIT_TELEPORT, 0.5, 1)
					target:teleport(event:getPlayer())
					target:getWorld():spawnParticle(import("$.Particle").REVERSE_PORTAL, target:getLocation():add(0,1,0), 1000, 0.1, 0.1, 0.1)
					target:getWorld():playSound(target:getLocation(), import("$.Sound").ITEM_CHORUS_FRUIT_TELEPORT, 0.5, 1)
				end
			end
		end
	end
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
			local guard = LAPlayer:getVariable("EX044-guard")
			if guard ~= nil and event:getEntity() == guard then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end
