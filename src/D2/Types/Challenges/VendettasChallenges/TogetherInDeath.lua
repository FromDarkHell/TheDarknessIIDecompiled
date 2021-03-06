targetTypes = {
  WeakResource()
}
timeBetweenKills = 5
local firstKillTime = 0
local numKilledTargets = 0
local killedTargets = {
  WeakResource(),
  WeakResource()
}
function Update(player, delta)
  if numKilledTargets == 0 then
    return 0
  end
  firstKillTime = firstKillTime + delta
  if firstKillTime > timeBetweenKills then
    return -1
  end
  return 0
end
function MatchAttackEvent(scriptDamageData, player)
  local victim = scriptDamageData:GetVictim()
  if IsNull(victim) then
    return false
  end
  local targetIndex = -1
  for i = 1, #targetTypes do
    if victim:IsA(targetTypes[i]) then
      targetIndex = i
      break
    end
  end
  if targetIndex < 0 then
    return false
  end
  for i = 1, #killedTargets do
    if killedTargets[i] == victim then
      return false
    end
  end
  numKilledTargets = numKilledTargets + 1
  killedTargets[numKilledTargets] = victim
  return 2 <= numKilledTargets and firstKillTime < timeBetweenKills
end
