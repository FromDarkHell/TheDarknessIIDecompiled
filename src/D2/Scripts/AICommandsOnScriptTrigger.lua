npcAvatarType = Type()
destination = Instance()
target = Instance()
shootTime = 1
run = true
align = true
exitOnAlert = false
exitOnCombat = false
exitOnDamage = false
exitOnEnemySeen = false
exitOnEnemySeenRadius = 10
neverExit = false
local setAgent = function(agent)
  if IsNull(agent) == false then
    agent:SetExitOnAlertAwareness(exitOnAlert)
    agent:SetExitOnCombatAwareness(exitOnCombat)
    agent:SetExitOnDamage(exitOnDamage)
    agent:SetExitOnEnemySeen(exitOnEnemySeen, exitOnEnemySeenRadius)
    if neverExit == true then
      agent:SetAllExits(false)
    end
  end
end
function MoveToPointShootTarget()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  local agent = avatar:GetAgent()
  setAgent(agent)
  agent:MoveTo(destination, run, true, true)
  Sleep(0)
  agent:ShootTarget(target, shootTime, align, true)
  agent:StopScriptedMode()
end
function MoveTo()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  local agent = avatar:GetAgent()
  setAgent(agent)
  agent:MoveTo(destination, run, align, true)
  Sleep(0)
  agent:StopScriptedMode()
end
function SetAlert()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  while IsNull(avatar) do
    avatar = gRegion:FindNearest(npcAvatarType, Vector())
    Sleep(0.5)
  end
  avatar:GetAgent():SetAlert()
end
function SetIdle()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  while IsNull(avatar) do
    avatar = gRegion:FindNearest(npcAvatarType, Vector())
    Sleep(0.5)
  end
  avatar:GetAgent():SetIdle()
end
