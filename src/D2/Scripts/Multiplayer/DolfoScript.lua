prePlantSpot = Instance()
plantBombNowCounter = Instance()
plantBombNowTimer = Instance()
plantBombNowTimerExpired = false
plantWarpingAnim = Resource()
plantWarpAnimpoint = Instance()
plantAnimpoint = Instance()
plantLoopAnim = Resource()
bombPlantedTimer = Instance()
bombPlantedTimerExpired = false
safeSpot = Instance()
duckAndCoverLoopAnim = Resource()
function OnTimerExpired(entity)
  if entity == plantBombNowTimer then
    plantBombNowTimerExpired = true
  elseif entity == bombPlantedTimer then
    bombPlantedTimerExpired = true
  end
end
local setAgent = function(agent)
  if IsNull(agent) == false then
    agent:SetExitOnAlertAwareness(false)
    agent:SetExitOnCombatAwareness(false)
    agent:SetExitOnDamage(false)
    agent:SetExitOnEnemySeen(false, 0)
    agent:SetAllExits(false)
    agent:UseAvoidance(false)
  end
end
function dolfoAction(agent)
  setAgent(agent)
  agent:MoveTo(prePlantSpot, true, true, true)
  plantBombNowCounter:FirePort("Increment")
  Sleep(0)
  if IsNull(plantBombNowTimer) == false then
    ObjectPortHandler(plantBombNowTimer, "OnTimerExpired")
  end
  while plantBombNowTimerExpired == false do
    Sleep(0)
  end
  agent:MoveTo(plantWarpAnimpoint, true, false, true)
  Sleep(0.5)
  agent:SetIdleAnimation(plantLoopAnim)
  agent:PlayWarpedAnimation(plantWarpingAnim, plantAnimpoint, true)
  agent:LoopAnimation(plantLoopAnim)
  if IsNull(bombPlantedTimer) == false then
    ObjectPortHandler(bombPlantedTimer, "OnTimerExpired")
  end
  while bombPlantedTimerExpired == false do
    Sleep(0)
  end
  agent:ClearScriptActions()
  agent:SetIdleAnimation(nil)
  agent:MoveTo(safeSpot, true, true, true)
  agent:LoopAnimation(duckAndCoverLoopAnim)
end
