cedroTag = Symbol()
guardSpawnerTag = Symbol()
numGuards = 3
local numGuardsKilled = 0
local initialized = false
function OnAgentDestroyed()
  numGuardsKilled = numGuardsKilled + 1
end
local Initialize = function()
  local guardSpawners = gRegion:FindTagged(guardSpawnerTag)
  ObjectPortHandler(guardSpawners[1], "OnAgentDestroyed")
end
function MatchAttackEvent(scriptDamageData, player)
  if not initialized then
    Initialize()
    initialized = true
  end
  local victim = scriptDamageData:GetVictim()
  if IsNull(victim) then
    return false
  end
  if numGuardsKilled == numGuards and victim:GetTag() == cedroTag then
    return true
  else
    return false
  end
end
