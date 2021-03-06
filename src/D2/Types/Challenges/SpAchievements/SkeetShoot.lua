avatarCollisionProxy = WeakResource()
function MatchAttackEvent(damageData, player)
  local victim = damageData:GetVictim()
  if not IsNull(victim) then
    local attachParent = victim:GetAttachParent()
    if not IsNull(attachParent) and attachParent:IsA(avatarCollisionProxy) then
      return true
    end
  end
  return false
end
