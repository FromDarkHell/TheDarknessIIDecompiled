forbiddenDamageSources = {
  WeakResource()
}
local challengeFailed = false
function MatchAttackEvent(scriptDamageData, player)
  if challengeFailed then
    return false
  end
  local damageSourceObject = scriptDamageData:GetSourceObject()
  if IsNull(damageSourceObject) then
    return false
  end
  for i = 1, #forbiddenDamageSources do
    if damageSourceObject:IsA(forbiddenDamageSources[i]) then
      challengeFailed = true
      break
    end
  end
  return false
end
function MatchTagEvent(player, tag)
  if tag == "ENDMISSION" then
    return not challengeFailed
  end
  return false
end
