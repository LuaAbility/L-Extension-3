function Init(abilityData)
	plugin.registerEvent(abilityData, "중력 전환", "PlayerInteractEvent", 1800)
	plugin.registerEvent(abilityData, "EX043-calculateDamage", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "중력 전환" then useAbility(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("EX043-abilityTime") == nil then 
		player:setVariable("EX043-abilityTime", 0) 
	end	

	local abilityTime = player:getVariable("EX043-abilityTime")
	if abilityTime > 0 then
		abilityTime = abilityTime - 1
		if abilityTime <= 0 then resetGravity(player)
		else gravity(player) end
		player:setVariable("EX043-abilityTime", abilityTime) 
	end
end

function useAbility(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					LAPlayer:setVariable("EX043-abilityTime", 200) 
					
					local players = util.getTableFromList(game.getTeamManager():getOpponentTeam(LAPlayer, false))
					for i = 1, #players do
						if players[i] ~= player then 
							players[i]:getPlayer():setVelocity(players[i]:getPlayer():getVelocity():add(newInstance("$.util.Vector", {0, 0.3, 0})))
						end
					end
				end
			end
		end
	end
end

function Reset(player, ability)
	resetGravity(player)
end

function resetGravity(player)
	local players = util.getTableFromList(game.getTeamManager():getOpponentTeam(player, false))
	for i = 1, #players do
		players[i]:getPlayer():setGravity(true)
	end
end

function gravity(player)
	local players = util.getTableFromList(game.getTeamManager():getOpponentTeam(player, false))
	for i = 1, #players do
		if game.targetPlayer(player, players[i], false) then 
			game.sendActionBarMessage(players[i]:getPlayer(), "§a중력 전환!")
			local addVector = newInstance("$.util.Vector", {0.1 + players[i]:getPlayer():getVelocity():getX() * 0.15, 0, 0})
			local velocity = players[i]:getPlayer():getVelocity():add(addVector)
			velocity:setY(velocity:getY() * 0.5)

			players[i]:getPlayer():setGravity(false)
			players[i]:getPlayer():setVelocity(velocity)
		end
	end
end
