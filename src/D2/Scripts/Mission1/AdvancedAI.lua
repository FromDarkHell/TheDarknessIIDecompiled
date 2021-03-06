positionWaypoints = {
  Instance()
}
coverWaypoints = {
  Instance()
}
targets = {
  Instance()
}
waitTimes = {0}
run = false
align = false
shootTime = 2
exitOnAlert = false
exitOnCombat = false
exitOnDamage = false
exitOnEnemySeen = false
exitOnEnemySeenRadius = 10
local setAgent = function(agent)
  if IsNull(agent) == false then
    agent:SetExitOnAlertAwareness(exitOnAlert)
    agent:SetExitOnCombatAwareness(exitOnCombat)
    agent:SetExitOnDamage(exitOnDamage)
    agent:SetExitOnEnemySeen(exitOnEnemySeen, exitOnEnemySeenRadius)
  end
end
function AdvancedMoveTo(agent)
  setAgent(agent)
  for i = 1, #positionWaypoints do
    agent:MoveTo(positionWaypoints[i], run, align, true)
    if IsNull(waitTimes[i]) == false then
      Sleep(waitTimes[i])
    else
      Sleep(0)
    end
  end
  agent:StopScriptedMode()
end
function MoveToRandomDestination(agent)
  setAgent(agent)
  local pos = RandomInt(1, #positionWaypoints)
  agent:MoveTo(positionWaypoints[pos], run, align, true)
  agent:StopScriptedMode()
end
function MoveToRandomCover(agent)
  setAgent(agent)
  local pos = RandomInt(1, #coverWaypoints)
  agent:EnterNearestCover(coverWaypoints[pos], true)
  agent:StopScriptedMode()
end
function RandomPatrol(agent)
  setAgent(agent)
  local wayNum = RandomInt(1, #positionWaypoints)
  local waypoint = positionWaypoints[wayNum]
  local oldWayNum = -1
  while true do
    if wayNum == oldWayNum then
      wayNum = RandomInt(1, #positionWaypoints)
    else
      oldWayNum = wayNum
      waypoint = positionWaypoints[wayNum]
      agent:MoveTo(waypoint, run, align, true)
      Sleep(1)
    end
  end
end
function SequentialPatrol(agent)
  setAgent(agent)
  while true do
    local i = 1
    while i <= #positionWaypoints do
      if agent:HasActions() == false then
        agent:MoveTo(positionWaypoints[i], run, align, true)
        i = i + 1
        if IsNull(waitTimes[i]) == false then
          Sleep(waitTimes[i])
        else
          Sleep(0)
        end
      end
      Sleep(0)
    end
  end
end
function LinearPatrol(agent)
  setAgent(agent)
  while true do
    local i = 1
    local inc = 1
    while true do
      if agent:HasActions() == false then
        agent:MoveTo(positionWaypoints[i], run, align, true)
        i = i + inc
        if IsNull(waitTimes[i]) == false then
          Sleep(waitTimes[i])
        else
          Sleep(0)
        end
        if i <= 1 or i >= #positionWaypoints then
          inc = inc * -1
        end
      end
      Sleep(0)
    end
  end
end
