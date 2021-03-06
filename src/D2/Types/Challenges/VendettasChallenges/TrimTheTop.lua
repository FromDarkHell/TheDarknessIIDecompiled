veteranType = WeakResource()
local numKilledOnTopFloor = 0
function Initialize()
end
function MatchAttackEvent(scriptDamageData, player)
  local victim = scriptDamageData:GetVictim()
  if IsNull(victim) then
    return false
  end
  local victimPos = victim:GetPosition()
  local topFloor = victimPos.y > 18
  if not topFloor then
    return false
  end
  if victim:IsA(veteranType) then
    return numKilledOnTopFloor == 0
  end
  numKilledOnTopFloor = 1
  return false
end
