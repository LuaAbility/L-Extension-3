local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "위치 확인", "PlayerInteractEvent", 200)
	plugin.registerEvent(abilityData, "BH001-cancelDamage", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "위치 확인" then showEffect(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "BH001-cancelDamage" then cancelDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.SPEED, 20, 0}))
end

function showEffect(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					blockEffect(LAPlayer)
					local itemStack = { newInstance("$.inventory.ItemStack", {event:getMaterial(), 1}) }
					event:getPlayer():getInventory():removeItem(itemStack)
				end
			end
		end
	end
end

function cancelDamage(LAPlayer, event, ability, id)
	if game.checkCooldown(LAPlayer, game.getPlayer(event:getDamager()), ability, id) then
		event:setDamage(8)
	end
	
	if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) then
		event:setDamage(0)
	end
end

function blockEffect(player)
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		if game.targetPlayer(player, players[i], false) and game.hasAbility(players[i], "LA-BH-HIDER-HIDDEN") then
			local loc = players[i]:getPlayer():getLocation()
			players[i]:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, players[i]:getPlayer():getLocation():add(0, -0.5, 0), 200, 0.5, 0.5, 0.5, 0.1)
			players[i]:getPlayer():getWorld():playSound(players[i]:getPlayer():getLocation(), import("$.Sound").ENTITY_ITEM_PICKUP, 0.5, 1)
			game.sendActionBarMessage(players[i]:getPlayer(), "§c" .. player:getPlayer():getName() .. "이(가) 위치를 확인하려 합니다!")
		end
	end
end