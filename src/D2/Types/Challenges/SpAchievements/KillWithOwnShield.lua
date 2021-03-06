d2npcType = WeakResource()
function MatchAttackEvent(damageData, player)
  local victim = damageData:GetVictim()
  if not IsNull(victim) and victim:IsA(d2npcType) then
    local sourceObject = damageData:GetSourceObject()
    local associatedShield = victim:GetAssociatedShield()
    if not IsNull(sourceObject) and not IsNull(associatedShield) and sourceObject == associatedShield then
      return true
    end
  end
  return false
end
