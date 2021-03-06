function MatchAttackEvent(damageData, player)
  local avatar = player:GetAvatar()
  local inventoryController = avatar:ScriptInventoryControl()
  local mainHandWeapon = inventoryController:GetWeaponInHand(Engine.MAIN_HAND)
  local offHandWeapon = inventoryController:GetWeaponInHand(Engine.OFF_HAND)
  if not IsNull(mainHandWeapon) and mainHandWeapon:IsOneHanded() and not IsNull(offHandWeapon) and offHandWeapon:IsOneHanded() and mainHandWeapon:GetName() ~= offHandWeapon:GetName() then
    return true
  end
  return false
end
