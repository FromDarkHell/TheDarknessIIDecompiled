referencePos = Vector()
local failureTag = Symbol("FAILED")
function MatchAttackEvent(scriptDamageData, player)
  local victim = scriptDamageData:GetVictim()
  if IsNull(victim) then
    return false
  end
  local victimPos = victim:GetPosition()
  local dpos = referencePos - victimPos
  local dist = dpos.x * dpos.x + dpos.z * dpos.z
  if dist < 4 then
    return true
  end
  local humans = gRegion:GetHumanPlayers()
  for i = 1, #humans do
    gChallengeMgr:NotifyTag(humans[i], failureTag)
  end
end
