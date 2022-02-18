function Init(abilityData)
	plugin.registerEvent(abilityData, "시간 역행", "PlayerInteractEvent", 900)
end

function onEvent(funcTable)
	if funcTable[1] == "시간 역행" then useAbility(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("EX041-data") == nil then player:setVariable("EX041-data", { }) end	
	saveDir(player)
end

function useAbility(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					local data = LAPlayer:getVariable("EX041-data")
					local gamemode = event:getPlayer():getGameMode()
					local gravity = event:getPlayer():hasGravity()
					
					event:getPlayer():setGameMode(import("$.GameMode").SPECTATOR)
					event:getPlayer():setGravity(false)	
					for i = #data, 1, -1 do
						util.runLater(function()
							local tables = data[i]
							event:getPlayer():setHealth(tables[1])
							event:getPlayer():setFoodLevel(tables[2])
							event:getPlayer():teleport(tables[3])
							if i <= 1 then
								event:getPlayer():setGameMode(gamemode)
								event:getPlayer():setGravity(gravity)	
							end
						end, #data - i)
					end
				end
			end
		end
	end
end

function saveDir(player)
	local data = player:getVariable("EX041-data") 
	local tables = {}
	table.insert(tables, player:getPlayer():getHealth())
	table.insert(tables, player:getPlayer():getFoodLevel())
	table.insert(tables, player:getPlayer():getLocation())
	
	table.insert(data, tables)
	if #data > 25 then table.remove(data, 1) end
end
