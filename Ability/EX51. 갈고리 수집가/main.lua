local types = import("$.entity.EntityType")
local material = import("$.Material")
local dustOption = newInstance("$.Particle$DustOptions", {import("$.Color").fromRGB(240, 0, 0), 1})
local dustOption2 = newInstance("$.Particle$DustOptions", {import("$.Color").fromRGB(120, 0, 0), 1})

function Init(abilityData)
	plugin.registerEvent(abilityData, "EX051-collectQuestion", "AsyncPlayerChatEvent", 0)
	plugin.registerEvent(abilityData, "EX051-useAbility", "PlayerInteractEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "EX051-collectQuestion" then collectQuestion(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "EX051-useAbility" then useAbility(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	local count = player:getVariable("EX050-currentQuestion")
	if count == nil then 
		player:setVariable("EX050-currentQuestion", 0) 
		count = 0
	end
	
	game.sendActionBarMessage(player:getPlayer(), "§a수집한 갈고리 §6: §b" .. count .. "개")
end

function collectQuestion(LAPlayer, event, ability, id)
	if event:getPlayer() ~= LAPlayer:getPlayer() then
		if string.find(event:getMessage(), "?") > 0 then
			LAPlayer:setVariable("EX050-currentQuestion", LAPlayer:getVariable("EX050-currentQuestion") + 1)
			LAPlayer:getPlayer():spawnParticle(import("$.Particle").SMOKE_NORMAL, LAPlayer:getPlayer():getLocation():add(0,1,0), 50, 0.5, 0.5, 0.5, 0.05)
			LAPlayer:getPlayer():playSound(LAPlayer:getPlayer():getLocation(), import("$.Sound").BLOCK_ANVIL_PLACE, 0.25, 2)
		end
	end
end

function useAbility(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					local question = LAPlayer:getVariable("EX050-currentQuestion")
					if question > 0 then
						LAPlayer:setVariable("EX050-currentQuestion", question - 1)
						local players = util.getTableFromList(game.getPlayers())
						for i = 1, #players do
							if players[i]:getPlayer() ~= event:getPlayer() then
								if event:getPlayer():getWorld():getEnvironment() == players[i]:getPlayer():getWorld():getEnvironment() and
								(event:getPlayer():getLocation():distance(players[i]:getPlayer():getLocation()) <= 30) and game.targetPlayer(LAPlayer, players[i], false) then
									local moveDir = newInstance("$.util.Vector", {
									players[i]:getPlayer():getLocation():getX() - player:getPlayer():getLocation():getX(), 
									players[i]:getPlayer():getLocation():getY() - player:getPlayer():getLocation():getY(), 
									players[i]:getPlayer():getLocation():getZ() - player:getPlayer():getLocation():getZ()})
									
									local dirLenfth = moveDir:length()
									moveDir:setX(moveDir:getX() / dirLenfth * -1)
									moveDir:setY((moveDir:getY() / dirLenfth * -1) + 0.4)
									moveDir:setZ(moveDir:getZ() / dirLenfth * -1)
									players[i]:getPlayer():setVelocity(moveDir)
									
									drawLine(players[i]:getPlayer():getLocation():add(0, 1, 0), player:getPlayer():getLocation():add(0, 1, 0))
								end
							end
						end
						
						event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").BLOCK_CHAIN_PLACE, 1, 0.6)
					else
						game.sendActionBarMessage(event:getPlayer(), "§4[§c갈고리 수집가§4] §c갈고리가 부족합니다!")
					end
				end
			end
		end
	end
	
	if event:getAction():toString() == "LEFT_CLICK_AIR" or event:getAction():toString() == "LEFT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					local question = LAPlayer:getVariable("EX050-currentQuestion")
					if question > 0 then
						LAPlayer:setVariable("EX050-currentQuestion", 0)
						local players = util.getTableFromList(game.getPlayers())
						for i = 1, #players do
							if players[i]:getPlayer() ~= event:getPlayer() then
								if event:getPlayer():getWorld():getEnvironment() == players[i]:getPlayer():getWorld():getEnvironment() and
								(event:getPlayer():getLocation():distance(players[i]:getPlayer():getLocation()) <= 30) and game.targetPlayer(LAPlayer, players[i], false) then
									players[i]:getPlayer():damage(question * 2, event:getPlayer())
									drawLine(players[i]:getPlayer():getLocation():add(0, 1, 0), player:getPlayer():getLocation():add(0, 1, 0))
									players[i]:getPlayer():getWorld():spawnParticle(particle.REDSTONE, players[i]:getPlayer():getLocation():add(0, 1.2, 0), 30, 0.05, 0.05, 0.05, 0.05, dustOption)
									players[i]:getPlayer():getWorld():spawnParticle(particle.REDSTONE, players[i]:getPlayer():getLocation():add(0, 1.2, 0), 50, 0.05, 0.05, 0.05, 0.05, dustOption2)
								end
							end
						end
						
						event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").BLOCK_CHAIN_BREAK, 1, 0.8)
					else
						game.sendActionBarMessage(event:getPlayer(), "§4[§c갈고리 수집가§4] §c갈고리가 부족합니다!")
					end
				end
			end
		end
	end
end

function drawLine(point1, point2)
    local world = point1:getWorld()
    local distance = point1:distance(point2)
    local p1 = point1:toVector()
    local p2 = point2:toVector()
    local vector = p2:clone():subtract(p1):normalize()
    for i = 0, distance do
		local loc = newInstance("$.Location", { world, p1:getX(), p1:getY(), p1:getZ() })
        world:spawnParticle(particle.SMOKE_NORMAL, loc, 50, 0.1, 0.1, 0.1, 0.05)
		p1:add(vector)
    end
end