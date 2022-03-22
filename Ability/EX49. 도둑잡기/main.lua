function Init(abilityData) 
	plugin.registerEvent(abilityData, "조커 카드 주기", "EntityDamageEvent", 0)
	plugin.registerEvent(abilityData, "EX049-curse", "AbilityConfirmEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "조커 카드 주기" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then abilityUse(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "EX049-curse" then cancelAbility(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability) 
	local count = player:getVariable("EX049-abilityTime")
	if count == nil then 
		player:setVariable("EX049-abilityTime", 600)
		count = 600
	end
	
	if count > 0 then
		count = count - 1
		
		if count == 0 then
            game.sendMessage(player:getPlayer(), "§1[§b도둑잡기§1] §b재사용 대기시간이 종료되었습니다. (조커 카드 주기)")
            player:getPlayer():playSound(player:getPlayer(), import("$.Sound").ENTITY_PLAYER_LEVELUP, 0.5, 2)
        elseif count == 20 then
			game.sendMessage(player:getPlayer(), "§1[§b도둑잡기§1] §b남은 시간 : 1초 (조커 카드 주기)")
			player:getPlayer():playSound(player:getPlayer(), import("$.Sound").ENTITY_EXPERIENCE_ORB_PICKUP, 0.5, 2)
        elseif count == 40 then
			game.sendMessage(player:getPlayer(), "§1[§b도둑잡기§1] §b남은 시간 : 2초 (조커 카드 주기)")
			player:getPlayer():playSound(player:getPlayer(), import("$.Sound").ENTITY_EXPERIENCE_ORB_PICKUP, 0.5, 2)
        elseif count == 60 then
			game.sendMessage(player:getPlayer(), "§1[§b도둑잡기§1] §b남은 시간 : 3초 (조커 카드 주기)")
			player:getPlayer():playSound(player:getPlayer(), import("$.Sound").ENTITY_EXPERIENCE_ORB_PICKUP, 0.5, 2)
        elseif count == 80 then
			game.sendMessage(player:getPlayer(), "§1[§b도둑잡기§1] §b남은 시간 : 4초 (조커 카드 주기)")
			player:getPlayer():playSound(player:getPlayer(), import("$.Sound").ENTITY_EXPERIENCE_ORB_PICKUP, 0.5, 2)
        elseif count == 100 then
			game.sendMessage(player:getPlayer(), "§1[§b도둑잡기§1] §b남은 시간 : 5초 (조커 카드 주기)")
			player:getPlayer():playSound(player:getPlayer(), import("$.Sound").ENTITY_EXPERIENCE_ORB_PICKUP, 0.5, 2)
		end
        
		player:setVariable("EX049-abilityTime", count)
	end
end

function abilityUse(LAPlayer, event, ability, id)
	if event:getDamager():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "PLAYER" then
		local item = event:getDamager():getInventory():getItemInMainHand()
		if game.isAbilityItem(item, "IRON_INGOT") and game.targetPlayer(LAPlayer, game.getPlayer(event:getEntity())) then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getDamager()), ability, id, true, false) then
				local count = LAPlayer:getVariable("EX049-abilityTime")
				if count then
					if count <= 0 then
						LAPlayer:setVariable("EX049-abilityTime", 600)
						util.runLater(function()
							game.removeAbility(LAPlayer, ability, false)
							game.addAbility(game.getPlayer(event:getEntity()), ability.abilityID)
							game.sendMessage(event:getEntity(), "§4[§c도둑잡기§4] §c조커 카드를 받았습니다! 액티브 능력 사용이 불가능합니다." )
						end, 1)
					else
						game.sendMessage(event:getDamager(), "§1[§b도둑잡기§1] §b재사용 대기시간 입니다. (" .. (count / 20) .. "초 / 조커 카드 주기)" )
					end
				end
			end
		end
	end
end

function cancelAbility(LAPlayer, event, ability, id)
	if LAPlayer == event:getPlayer() then
		event:setCancelled(true)
	end
end