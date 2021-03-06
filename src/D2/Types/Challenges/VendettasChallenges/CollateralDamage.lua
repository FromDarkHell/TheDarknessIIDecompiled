local challengeFailed = false
function MatchAttackEvent(scriptDamageData, player)
  local victim = scriptDamageData:GetVictim()
  if IsNull(victim) or challengeFailed then
    return false
  end
  local victimPos = victim:GetPosition()
  local archiveFloor = victimPos.y > -24 and victimPos.y < -10
  if archiveFloor then
    challengeFailed = true
  end
  return false
end
function MatchTagEvent(player, tag)
  if tag == "ENDMISSION" then
    return not challengeFailed
  end
  return false
end
