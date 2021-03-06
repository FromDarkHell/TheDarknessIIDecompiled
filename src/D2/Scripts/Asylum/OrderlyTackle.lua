dest = Instance()
idleAnim = Resource()
guardAnim = Resource()
run = true
align = false
exitOnAlert = false
exitOnCombat = false
exitOnDamage = false
exitOnEnemySeen = false
exitOnEnemySeenRadius = 10
useAvoidance = true
neverExit = false
isAnimLooping = false
attackRange = 0
guardRange = 0
startFadeTime = 2
fadeToChangeTime = 1
fadeToFinalValue = 1
test = 1
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
function moveToAnim(agent)
  local player = gRegion:GetPlayerAvatar()
  local avatar = agent:GetAvatar()
  local outsideAttackRange = true
  local idling = false
  local guarding = true
  setAgent(agent)
  agent:MoveTo(dest, run, align, true)
  local distance = Distance(player:GetPosition(), avatar:GetPosition())
  if distance < attackRange then
    outsideAttackRange = false
  end
  while outsideAttackRange do
    Sleep(0)
    if IsNull(avatar) == true or IsNull(agent) == true then
      break
    end
    distance = Distance(player:GetPosition(), avatar:GetPosition())
    if distance < attackRange then
      outsideAttackRange = false
      break
    elseif distance < guardRange and not guarding then
      agent:SetAim(true)
      guarding = true
    elseif distance >= guardRange and guarding then
      agent:SetAim(false)
      agent:SetTarget(player)
      guarding = false
    end
  end
  agent:StopScriptedMode()
end
local Fade = function(changeTime, finalValue)
  local playerAvatar = gRegion:GetPlayerAvatar()
  local postProcess = gRegion:GetLevelInfo().postProcess
  local startFade = postProcess.fade
  Sleep(0.01)
  if changeTime == 0 then
    postProcess.fade = finalValue
    Sleep(0)
    return
  end
  local t = 0
  local val
  while t < 1 do
    val = Lerp(startFade, finalValue, t)
    postProcess.fade = val
    t = t + DeltaTime() / changeTime
    Sleep(0)
  end
  postProcess.fade = finalValue
  Sleep(0)
end
function RestartOnFinisher(agent)
  local player = gRegion:GetPlayerAvatar()
  local loop = true
  while loop do
    if player:IsDoingFinisher() then
      loop = false
    end
    Sleep(0)
  end
  Sleep(startFadeTime)
  Fade(fadeToChangeTime, fadeToFinalValue)
  gRegion:GetGameRules():RestartCheckPoint()
end
