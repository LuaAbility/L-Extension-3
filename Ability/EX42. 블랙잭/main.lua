function Init(abilityData)
	plugin.registerEvent(abilityData, "숫자 뽑기", "PlayerInteractEvent", 60)
	plugin.registerEvent(abilityData, "EX042-calculateDamage", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "숫자 뽑기" then useAbility(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "EX042-calculateDamage" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then calculateDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("EX042-abilityTime") == nil then 
		player:setVariable("EX042-abilityTime", 0) 
		player:setVariable("EX042-attack", 1) 
		player:setVariable("EX042-defense", 1) 
		player:setVariable("EX042-count", 0) 
	end	
	
	local count = player:getVariable("EX042-count")
	local currentText = "§e누적 : " .. count
	if count ~= 0 then
		if count == 21 then currentText = currentText .. " §6[§e공격력 1.5배 / 피격 데미지 0.5배§e]"
		elseif count > 21 then currentText = currentText .. " §4[§c공격력 0배§4]"
		elseif (count % 2) == 1 then currentText = currentText .. " §1[§b공격력 1.25배§1]"
		elseif (count % 2) == 0 then currentText = currentText .. " §2[§a피격 데미지 0.75배§2]" end
	end
	
	game.sendActionBarMessage(player:getPlayer(), currentText)
	setVariable(player)
	
	local abilityTime = player:getVariable("EX042-abilityTime")
	if abilityTime > 0 then
		abilityTime = abilityTime - 1
		if abilityTime <= 0 then
			game.sendMessage(player:getPlayer(), "§1[§b블랙잭§1] §b누적 숫자가 초기화됩니다.")
			player:setVariable("EX042-count", 0)
			player:getPlayer():playSound(player:getPlayer():getLocation(), import("$.Sound").BLOCK_BEACON_DEACTIVATE, 0.5, 1)
		end
		player:setVariable("EX042-abilityTime", abilityTime) 
	end
end

function useAbility(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") and LAPlayer:getVariable("EX042-count") < 21 then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					local randomInt = util.random(1, 10)
					local count = LAPlayer:getVariable("EX042-count") + randomInt
					
					game.sendMessage(event:getPlayer(), "§6[§e블랙잭§6] §e추첨된 숫자 : " .. randomInt)
					if count == 21 then
						game.sendMessage(event:getPlayer(), "§6[§e블랙잭§6] Blackjack!")
						game.sendMessage(event:getPlayer(), "§6[§e블랙잭§6] §e공격력 1.5배 / 피격 데미지 0.5배가 적용됩니다.")
						event:getPlayer():getWorld():spawnParticle(import("$.Particle").REDSTONE, event:getPlayer():getLocation():add(0,1,0), 150, 0.5, 0.7, 0.5, 0.5, newInstance("$.Particle$DustOptions", {import("$.Color").ORANGE, 1}))
						event:getPlayer():playSound(event:getPlayer():getLocation(), import("$.Sound").UI_TOAST_CHALLENGE_COMPLETE, 0.5, 1)
						LAPlayer:setVariable("EX042-abilityTime", 600) 
					elseif count > 21 then
						game.sendMessage(event:getPlayer(), "§4[§c블랙잭§4] Burst...")
						game.sendMessage(event:getPlayer(), "§4[§c블랙잭§4] §c공격력 0배가 적용됩니다.")
						event:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, event:getPlayer():getLocation():add(0,1,0), 150, 0.5, 0.7, 0.5, 0.05)
						event:getPlayer():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_WITHER_AMBIENT, 0.5, 1)
						LAPlayer:setVariable("EX042-abilityTime", 600) 
					elseif (count % 2) == 1 then
						game.sendMessage(event:getPlayer(), "§1[§b블랙잭§1] §b누적된 숫자가 홀수입니다.")
						game.sendMessage(event:getPlayer(), "§1[§b블랙잭§1] §b공격력 1.25배가 적용됩니다.")
						event:getPlayer():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_EXPERIENCE_ORB_PICKUP, 0.5, 1)
						event:getPlayer():getWorld():spawnParticle(import("$.Particle").REDSTONE, event:getPlayer():getLocation():add(0,1,0), 150, 0.5, 0.7, 0.5, 0.5, newInstance("$.Particle$DustOptions", {import("$.Color").AQUA, 2}))
					elseif (count % 2) == 0 then
						game.sendMessage(event:getPlayer(), "§2[§a블랙잭§2] §a누적된 숫자가 짝수입니다.")
						game.sendMessage(event:getPlayer(), "§2[§a블랙잭§2] §a피격 데미지 0.75배가 적용됩니다.")
						event:getPlayer():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_EXPERIENCE_ORB_PICKUP, 0.5, 1)
						event:getPlayer():getWorld():spawnParticle(import("$.Particle").REDSTONE, event:getPlayer():getLocation():add(0,1,0), 150, 0.5, 0.7, 0.5, 0.5, newInstance("$.Particle$DustOptions", {import("$.Color").LIME, 2}))
					end
					
					LAPlayer:setVariable("EX042-count", count)
				end
			end
		end
	end
end

function setVariable(player)
	if player:getVariable("EX042-count") == 0 then
		player:setVariable("EX042-attack", 1) 
		player:setVariable("EX042-defense", 1)
	elseif player:getVariable("EX042-count") == 21 then
		player:setVariable("EX042-attack", 1.5) 
		player:setVariable("EX042-defense", 0.5)
		player:getPlayer():getWorld():spawnParticle(import("$.Particle").REDSTONE, player:getPlayer():getLocation():add(0,1,0), 20, 0.5, 0.7, 0.5, 0.5, newInstance("$.Particle$DustOptions", {import("$.Color").ORANGE, 1}))
	elseif player:getVariable("EX042-count") > 21 then
		player:setVariable("EX042-attack", 0) 
		player:setVariable("EX042-defense", 1)
		player:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, player:getPlayer():getLocation():add(0,1,0), 40, 0.5, 0.7, 0.5, 0.05)
	elseif (player:getVariable("EX042-count") % 2) == 1 then
		player:setVariable("EX042-attack", 1.25) 
		player:setVariable("EX042-defense", 1)
		player:getPlayer():getWorld():spawnParticle(import("$.Particle").REDSTONE, player:getPlayer():getLocation():add(0,1,0), 20, 0.5, 0.7, 0.5, 0.5, newInstance("$.Particle$DustOptions", {import("$.Color").AQUA, 1}))
	elseif (player:getVariable("EX042-count") % 2) == 0 then
		player:setVariable("EX042-attack", 1) 
		player:setVariable("EX042-defense", 0.75)
		player:getPlayer():getWorld():spawnParticle(import("$.Particle").REDSTONE, player:getPlayer():getLocation():add(0,1,0), 20, 0.5, 0.7, 0.5, 0.5, newInstance("$.Particle$DustOptions", {import("$.Color").LIME, 1}))
	end
end

function calculateDamage(LAPlayer, event, ability, id)
	local damagee = event:getEntity()
	local damager = event:getDamager()
	if event:getCause():toString() == "PROJECTILE" then damager = event:getDamager():getShooter() end
	
	if not util.hasClass(damager, "org.bukkit.projectiles.BlockProjectileSource") and damager:getType():toString() == "PLAYER" and damagee:getType():toString() == "PLAYER" then
		if game.checkCooldown(LAPlayer, game.getPlayer(damagee), ability, id) then
			print(event:getDamage() * LAPlayer:getVariable("EX042-defense"))
			event:setDamage(event:getDamage() * LAPlayer:getVariable("EX042-defense"))
		end
		if game.checkCooldown(LAPlayer, game.getPlayer(damager), ability, id) then
			event:setDamage(event:getDamage() * LAPlayer:getVariable("EX042-attack"))
		end
	end
end
