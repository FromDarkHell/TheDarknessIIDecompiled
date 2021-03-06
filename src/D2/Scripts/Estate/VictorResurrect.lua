maxResurrectDistance = 20
minResurrectDistance = 5
npcResurrectSpawnController = Instance()
npcResurrectSpawnControllerType = Type()
npcAgentTypes = {
  Type()
}
timeBetweenSpawns = 0
numberOfSpawns = 3
respawnThreshold = 1
combatWaypoints = {
  Instance()
}
resurrectWaypoint = Instance()
victorAvatarType = Type()
resurrectState = true
portTimer = Instance()
local EnableWaypoints = function(waypointArray)
  for i = 1, #waypointArray do
    waypointArray[i]:FirePort("Enable")
  end
end
local DisableWaypoints = function(waypointArray)
  for i = 1, #waypointArray do
    waypointArray[i]:FirePort("Disable")
  end
end
local FindAllNearestSpawns = function(victorAvatar)
  local playerAvatar = gRegion:GetPlayerAvatar()
  local spawns = gRegion:FindAll(npcResurrectSpawnControllerType, victorAvatar:GetPosition(), minResurrectDistance, maxResurrectDistance)
  local maxDistance = maxResurrectDistance
  local tries = 0
  while true do
    if not (IsNull(spawns) or #spawns < numberOfSpawns) or 10 <= tries then
      break
    end
    maxDistance = maxDistance + 2
    tries = tries + 1
    spawns = gRegion:FindAll(npcResurrectSpawnControllerType, playerAvatar:GetPosition(), minResurrectDistance, maxDistance)
    Sleep(0)
  end
  if 10 <= tries then
    Broadcast("FindAllNearestSpawns -> Couldn't find enough spawn controllers for resurrection!")
  end
  return spawns
end
local GetActiveAgentCount = function()
  local totalActiveAgents = 0
  local activeAgents
  local forLimit = #_T.gUsedSpawnControllers
  local i = 1
  while forLimit >= i do
    activeAgents = _T.gUsedSpawnControllers[i]:GetActiveCount()
    if activeAgents == 0 then
      table.remove(_T.gUsedSpawnControllers, i)
      forLimit = forLimit - 1
    else
      totalActiveAgents = totalActiveAgents + activeAgents
    end
    i = i + 1
  end
  return totalActiveAgents
end
local LinearSearch = function(object, list)
  if IsNull(list) then
    return false
  end
  for i = 1, #list do
    if list[i] == object then
      return true
    end
    Sleep(0)
  end
  return false
end
function VictorResurrect()
  if IsNull(npcResurrectSpawnController) then
    Broadcast("No spawn controllers available, exiting")
    return
  end
  for i = 1, numberOfSpawns do
    npcResurrectSpawnController:ScriptedSetAgentType(npcAgentTypes[math.random(1, #npcAgentTypes)])
    npcResurrectSpawnController:SpawnAgent()
    Sleep(timeBetweenSpawns)
  end
end
function NotifyAllAgentsKilled()
  while npcResurrectSpawnController:GetActiveCount() > 0 do
    Sleep(1)
  end
  portTimer:FirePort("Start")
end
function StoreWaypointsInGlobalTable()
  _T.gResurrectWaypoint = resurrectWaypoint
  _T.gCombatWaypoints = combatWaypoints
end
