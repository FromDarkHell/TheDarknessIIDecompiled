darklingAvatarType = Type()
darklingAgentType = Type()
darklingSpawnFx = Type()
positionWaypoint = Instance()
damageMultiplier = 1
delay = 0
function DarklingMoveTo()
  Sleep(delay)
  local player = gRegion:GetPlayerAvatar()
  local darklingAvatar = gRegion:FindNearest(darklingAvatarType, player:GetPosition(), INF)
  local darklingAgent = darklingAvatar:GetAgent()
  darklingAgent:ClearTarget()
  darklingAgent:StopCurrentBehavior()
  Sleep(0.1)
  darklingAgent:SetExitOnEnemySeen(false, 2)
  darklingAgent:SetExitOnCombatAwareness(false)
  darklingAgent:MoveTo(positionWaypoint, true, false, true)
  darklingAgent:StopScriptedMode()
end
function KillDarkling()
  local darkling = gRegion:FindNearest(darklingAvatarType, Vector(), INF)
  darkling:Destroy()
end
function PositionDarkling()
  local player = gRegion:GetPlayerAvatar()
  local darkling = gRegion:FindNearest(darklingAvatarType, player:GetPosition(), INF)
  local pos = positionWaypoint:GetPosition()
  local rot = positionWaypoint:GetRotation()
  if IsNull(darkling) == false then
    darkling:Destroy()
  end
  gRegion:CreateEntity(darklingSpawnFx, pos, rot)
  gRegion:CreateEntity(darklingAgentType, pos, rot)
end
function DarklingEnterCover()
  local player = gRegion:GetPlayerAvatar()
  local darklingAvatar = gRegion:FindNearest(darklingAvatarType, player:GetPosition(), INF)
  local darklingAgent = darklingAvatar:GetAgent()
  darklingAgent:SetAllExits(false)
  Sleep(0)
  darklingAgent:EnterNearestCover(positionWaypoint, true)
end
function DarklingEnterCoverFromSpawn(darklingAgent)
  darklingAgent:ClearTarget()
  darklingAgent:StopCurrentBehavior()
  Sleep(0.1)
  darklingAgent:SetExitOnEnemySeen(false, 2)
  darklingAgent:SetExitOnCombatAwareness(false)
  darklingAgent:EnterNearestCover(positionWaypoint, true)
end
function DarklingSetDamageMultiplier()
  local darklingAvatar = gRegion:FindNearest(darklingAvatarType, Vector(), INF)
  local damageController
  while IsNull(darklingAvatar) do
    darklingAvatar = gRegion:FindNearest(darklingAvatarType, Vector(), INF)
    Sleep(0)
  end
  damageController = darklingAvatar:DamageControl()
  damageController:SetDamageMultiplier(damageMultiplier)
end
function DarklingStopScriptedMode()
  local player = gRegion:GetPlayerAvatar()
  local darklingAvatar = gRegion:FindNearest(darklingAvatarType, player:GetPosition(), INF)
  local darklingAgent = darklingAvatar:GetAgent()
  darklingAgent:StopScriptedMode()
end
