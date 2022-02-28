local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "EX047-cancelAbility", "PlayerTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "EX047-cancelAbility" then cancel(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function cancel(LAPlayer, event, ability, id)
	if game.checkCooldown(LAPlayer, event:getTargetPlayer(), ability, id, false) then
		event:setCancelled(true)
	end
end
