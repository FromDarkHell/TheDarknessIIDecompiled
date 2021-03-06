wdestinationA = Instance()
startBombPlantTimer = Instance()
destinationB = Instance()
preplantingAnims = {
  Resource()
}
plantingAnim = Resource()
bombPlantLoopAnim = Resource()
bombPlantedTimer = Instance()
leaveSubwayTimer = Instance()
destinationC = Instance()
duckAndCoverLoopAnim = Resource()
alertCutToTheChaseTimer = Instance()
run = true
align = false
DolfoMPAvatar = Type()
dolfoCoverPoints = {
  Instance()
}
dolfoMoveUpTimer = Instance()
defenseVolume = Instance()
stopDolfoTravel = false
waypoint = Instance()
local timerExpired = false
local timerExpired2 = false
local timerExpired3 = false
local timerExpired4 = false
local DolfoLocation
local shouldDolfoMoveUp = false
function OnTimerExpired(entity)
  if entity == startBombPlantTimer then
    timerExpired = true
  elseif entity == bombPlantedTimer then
    timerExpired2 = true
  elseif entity == alertCutToTheChaseTimer then
    timerExpired = true
    timerExpired3 = true
    run = true
  elseif entity == leaveSubwayTimer then
    timerExpired4 = true
  elseif entity == dolfoMoveUpTimer then
    DolfoLocation = DolfoLocation + 1
    shouldDolfoMoveUp = true
  end
end
function Start()
  local agent, avatar, currentDV
  _T.gDolfoTravel = true
  if IsNull(agent) then
    while IsNull(avatar) do
      avatar = gRegion:FindNearest(DolfoMPAvatar, Vector(), INF)
      Sleep(0)
    end
    _T.gDolfoAgent = avatar:GetAgent()
    agent = _T.gDolfoAgent
  end
  currentDV = defenseVolume
  _T.gNextDV = defenseVolume
  agent:SetDefenseVolume(defenseVolume, true)
  while _T.gDolfoTravel or currentDV ~= _T.gNextDV do
    Sleep(1)
    if currentDV ~= _T.gNextDV then
      currentDV = _T.gNextDV
      agent:SetDefenseVolume(_T.gNextDV, true)
      agent:ExitCover()
      if not IsNull(_T.gDolfoWaypoint) then
        agent:SetExitOnEnemySeen(true, 20)
        agent:MoveTo(_T.gDolfoWaypoint, true, true, true)
        _T.gDolfoWaypoint = nil
        agent:SetExitOnEnemySeen(false, 20)
      end
      agent:StopScriptedMode()
    end
  end
end
function SetNewDefenseVolume()
  _T.gNextDV = defenseVolume
  _T.gDolfoTravel = not stopDolfoTravel
  _T.gDolfoWaypoint = waypoint
end
function StartOld()
  local agent, avatar
  if IsNull(DolfoLocation) then
    DolfoLocation = 1
  end
  if IsNull(agent) then
    while IsNull(avatar) do
      avatar = gRegion:FindNearest(DolfoMPAvatar, Vector(), INF)
      Sleep(0)
    end
    _T.gDolfoAgent = avatar:GetAgent()
    agent = _T.gDolfoAgent
  end
  if IsNull(startBombPlantTimer) == false then
    ObjectPortHandler(startBombPlantTimer, "OnTimerExpired")
  end
  if IsNull(bombPlantedTimer) == false then
    ObjectPortHandler(bombPlantedTimer, "OnTimerExpired")
  end
  if IsNull(leaveSubwayTimer) == false then
    ObjectPortHandler(leaveSubwayTimer, "OnTimerExpired")
  end
  if IsNull(bombPlantedTimer) == false then
    ObjectPortHandler(alertCutToTheChaseTimer, "OnTimerExpired")
  end
  if IsNull(dolfoMoveUpTimer) == false then
    ObjectPortHandler(dolfoMoveUpTimer, "OnTimerExpired")
  end
  agent:SetAllExits(false)
  while DolfoLocation <= #dolfoCoverPoints do
    if shouldDolfoMoveUp then
      if not IsNull(agent) then
        agent:MoveTo(dolfoCoverPoints[DolfoLocation], run, align, false)
      end
      if not IsNull(agent) then
        agent:EnterNearestCover(dolfoCoverPoints[DolfoLocation], false)
      end
      shouldDolfoMoveUp = false
    end
    Sleep(0)
  end
  while timerExpired == false do
    Sleep(1)
  end
end
function PlantBomb()
  local agent, avatar
  if IsNull(agent) then
    while IsNull(avatar) do
      avatar = gRegion:FindNearest(DolfoMPAvatar, Vector(), INF)
      Sleep(0)
    end
    _T.gDolfoAgent = avatar:GetAgent()
    agent = _T.gDolfoAgent
  end
  if IsNull(bombPlantedTimer) == false then
    ObjectPortHandler(bombPlantedTimer, "OnTimerExpired")
  end
  agent:MoveTo(destinationB, run, align, true)
  for i = 1, #preplantingAnims do
    if agent:HasActions() == false then
      agent:PlayAnimation(preplantingAnims[i], true)
    else
      i = i - 1
      if i == 14 then
        while timerExpired4 == false do
          Sleep(0.5)
        end
      end
    end
    if timerExpired3 == true then
      break
    end
    Sleep(0)
  end
  agent:MoveTo(destinationB, run, align, true)
  agent:LoopAnimation(bombPlantLoopAnim)
  while timerExpired2 == false do
    Sleep(0)
  end
  agent:ClearScriptActions()
  agent:MoveTo(destinationC, run, align, true)
  agent:LoopAnimation(duckAndCoverLoopAnim)
end
