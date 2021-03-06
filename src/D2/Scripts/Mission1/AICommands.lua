coverWaypoint = Instance()
dest = Instance()
targ = Instance()
shootTime = 1
Anim = Resource()
action = Instance()
run = true
align = false
hose = Instance()
exitOnAlert = false
exitOnCombat = false
exitOnDamage = false
exitOnEnemySeen = false
exitOnEnemySeenRadius = 10
useAvoidance = true
neverExit = false
isAnimLooping = false
local lobotomizeAgent = function(agent)
  if IsNull(agent) == false then
    agent:SetExitOnAlertAwareness(false)
    agent:SetExitOnCombatAwareness(false)
    agent:SetExitOnDamage(false)
    agent:SetExitOnEnemySeen(false, exitOnEnemySeenRadius)
  end
end
local restoreAgent = function(agent)
  if IsNull(agent) == false then
    agent:SetExitOnAlertAwareness(true)
    agent:SetExitOnCombatAwareness(true)
    agent:SetExitOnDamage(true)
    agent:SetExitOnEnemySeen(true, exitOnEnemySeenRadius)
  end
end
local setAgent = function(agent)
  if IsNull(agent) == false then
    agent:SetExitOnAlertAwareness(exitOnAlert)
    agent:SetExitOnCombatAwareness(exitOnCombat)
    agent:SetExitOnDamage(exitOnDamage)
    agent:SetExitOnEnemySeen(exitOnEnemySeen, exitOnEnemySeenRadius)
    if neverExit == true then
      agent:SetAllExits(false)
    end
    agent:UseAvoidance(useAvoidance)
  end
end
function SetPerceptions(agent)
  if IsNull(agent) == false then
    setAgent(agent)
  end
end
function takeCover(agent)
  setAgent(agent)
  if IsNull(coverWaypoint) == false then
    agent:EnterNearestCover(coverWaypoint, true)
  end
  Sleep(0)
  agent:StopScriptedMode()
end
function moveTo(agent)
  setAgent(agent)
  agent:MoveTo(dest, run, align, true)
  Sleep(0)
  agent:StopScriptedMode()
end
function moveToCover(agent)
  setAgent(agent)
  if IsNull(coverWaypoint) == false then
    agent:EnterNearestCover(coverWaypoint, true)
  end
  Sleep(0)
  agent:StopScriptedMode()
end
function moveToCoverShootPlayer(agent)
  setAgent(agent)
  local player = gRegion:GetPlayerAvatar()
  if IsNull(coverWaypoint) == false then
    agent:EnterNearestCover(coverWaypoint, true)
  end
  Sleep(0)
  agent:ShootTargetAvatar(player, shootTime, align, true)
  agent:StopScriptedMode()
end
function holdPosition(agent)
  setAgent(agent)
  Sleep(5)
  agent:StopScriptedMode()
end
function holdPositionShootPlayer(agent)
  setAgent(agent)
  local player = gRegion:GetPlayerAvatar()
  local npcAvatar = agent:GetAvatar()
  while IsNull(agent) == false or IsNull(npcAvatar) == false do
    if agent:HasActions() == false or agent:LastActionFailed() == true then
      agent:ShootTargetAvatar(player, shootTime, align, true)
    end
    Sleep(0)
  end
  agent:StopScriptedMode()
end
function shootTarget(agent)
  setAgent(agent)
  if IsNull(targ) == false then
    agent:SetTarget(targ)
    agent:ShootTarget(targ, shootTime, align, true)
  end
  Sleep(0)
  agent:StopScriptedMode()
end
function playAnim(agent)
  local avatar = agent:GetAvatar()
  setAgent(agent)
  if isAnimLooping == true then
    agent:LoopAnimation(Anim)
  else
    agent:PlayAnimation(Anim, true)
  end
end
function playSimpleAnim(agent)
  agent:PlayAnimation(Anim, true)
end
function moveToAnim(agent)
  local avatar = agent:GetAvatar()
  setAgent(agent)
  agent:MoveTo(dest, run, align, true)
  agent:PlayAnimation(Anim, false)
  while isAnimLooping do
    Sleep(0)
    if agent:HasActions() == false then
      agent:PlayAnimation(Anim, true)
    end
    if IsNull(avatar) == true or IsNull(agent) == true then
      break
    end
  end
  agent:StopScriptedMode()
end
function useContext(agent)
  setAgent(agent)
  if IsNull(action) == false then
    agent:UseContextAction(action, true)
  else
  end
  agent:StopScriptedMode()
end
function MoveToPointShootTarget(agent)
  setAgent(agent)
  agent:MoveTo(dest, run, true, true)
  Sleep(0)
  agent:ShootTarget(targ, shootTime, align, true)
  agent:StopScriptedMode()
end
function moveToDie(agent)
  setAgent(agent)
  agent:MoveTo(dest, run, true, false)
  Sleep(2)
  hose:FirePort("Start")
end
function ContextMoveTo(agent)
  setAgent(agent)
  if IsNull(action) == false then
    agent:UseContextAction(action, true)
  end
  Sleep(0)
  agent:MoveTo(dest, run, align, true)
  agent:StopScriptedMode()
end
function ContextMoveToCover(agent)
  setAgent(agent)
  if IsNull(action) == false then
    agent:UseContextAction(action, true)
  end
  if IsNull(coverWaypoint) == false then
    agent:EnterNearestCover(coverWaypoint, true)
  end
  agent:StopScriptedMode()
end
