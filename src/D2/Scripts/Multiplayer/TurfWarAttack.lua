civilianAvatarType = Type()
totalEnemies = 15
startMissionScriptTriggerTag = Symbol()
endMissionScriptTriggerTag = Symbol()
playerJoinedScriptTriggerTag = Symbol()
mainObjective = Symbol()
mainObjectiveDelay = 0.1
missionChallengeTag = Symbol()
endMissionDelay = 5
showNpcArrowsThreshold = 0
showNpcArrowsSpawnControls = {
  Instance()
}
enemyAvatarType = Type()
local emptyTag = Symbol()
local nilType = Type()
local mainObjectiveAddDelay = -1
local enemyKillsSymbol = Symbol("ENEMYKILLS")
local endMissionFadeDuration = 4
local endMissionTag = Symbol("ENDMISSION")
local function ExecuteScripts(triggerTag)
  if triggerTag == emptyTag then
    return
  end
  local scripts = gRegion:FindTagged(triggerTag)
  if not IsNull(scripts) then
    for t = 1, #scripts do
      scripts[t]:FirePort("Execute")
    end
  end
end
local function IsCivilian(victimAvatar)
  if IsNull(civilianAvatarType) or civilianAvatarType == nilType then
    return false
  end
  return victimAvatar:IsA(civilianAvatarType)
end
local function CompleteChallenge()
  if missionChallengeTag == emptyTag then
    return
  end
  local humans = gRegion:GetHumanPlayers()
  for i = 1, #humans do
    gChallengeMgr:NotifyTag(humans[i], missionChallengeTag)
    gChallengeMgr:NotifyTag(humans[i], endMissionTag)
  end
end
local DisableAI = function(agent)
  if IsNull(agent) == false then
    agent:SetExitOnAlertAwareness(false)
    agent:SetExitOnCombatAwareness(false)
    agent:SetExitOnDamage(false)
    agent:SetExitOnEnemySeen(false, 0)
  end
end
local function EscapeFromPlayer(agent, agentPos)
  local run = true
  local align = false
  local player = gRegion:GetLocalPlayer()
  local playerPos = player:GetPosition()
  local fromPlayerDir = agentPos - playerPos
  Normalize(fromPlayerDir)
  local escapePos = agentPos + fromPlayerDir * 15
  agent:FindNearestNavMeshPos(escapePos, 10)
  DisableAI(agent)
  agent:MoveToVector(escapePos, run, align, false)
end
local function ForceEscape()
  local avatars = gRegion:FindAll(enemyAvatarType, Vector(0, 0, 0), 0, INF)
  if IsNull(avatars) then
    return
  end
  for i = 1, #avatars do
    local avatar = avatars[i]
    if not IsNull(avatar) then
      local agent = avatar:GetAgent()
      if not IsNull(agent) then
        EscapeFromPlayer(agent, avatar:GetPosition())
      end
    end
  end
end
local GetGameState = function()
  local player = gRegion:GetLocalPlayer()
  local teamId = player:GetPlayer():GetTeam()
  return gRegion:GetGameRules():GetGameState(teamId)
end
local function AddMainObjective()
  local gameState = GetGameState()
  gameState:AddObjective(mainObjective)
end
local function RemoveMainObjective()
  local gameState = GetGameState()
  gameState:CompleteObjective(mainObjective)
end
local function UpdateNpcArrows()
  if showNpcArrowsThreshold <= 0 then
    return
  end
  local numAgents = 0
  for i = 1, #showNpcArrowsSpawnControls do
    numAgents = numAgents + showNpcArrowsSpawnControls[i]:GetActiveCount()
  end
  if numAgents < showNpcArrowsThreshold then
    local gameState = GetGameState()
    for i = 1, #showNpcArrowsSpawnControls do
      gameState:AddTrackedObject(Symbol(""), showNpcArrowsSpawnControls[i])
    end
    showNpcArrowsThreshold = 0
  end
end
local function CheckEndGameConditions(mpRules, enemyKills)
  local enemiesLeft = totalEnemies - enemyKills
  if enemiesLeft == 0 then
    ExecuteScripts(endMissionScriptTriggerTag)
    if mainObjective ~= emptyTag then
      RemoveMainObjective()
    end
    if not IsNull(enemyAvatarType) then
      ForceEscape()
    end
    CompleteChallenge()
    if 0 < endMissionDelay then
      Sleep(endMissionDelay)
    end
    mpRules:EndGame(Engine.GameRules_GS_SUCCESS, endMissionFadeDuration)
  else
    UpdateNpcArrows()
  end
end
function OnLevelLoaded(mpRules)
  ExecuteScripts(startMissionScriptTriggerTag)
end
function OnUpdate(mpRules, delta)
  if 0 < mainObjectiveAddDelay then
    mainObjectiveAddDelay = mainObjectiveAddDelay - delta
    if mainObjectiveAddDelay <= 0 then
      mainObjectiveAddDelay = 0
      AddMainObjective()
    end
  end
end
function OnPlayerConnected(mpRules, p)
  ExecuteScripts(playerJoinedScriptTriggerTag)
end
function OnDeath(mpRules, victimAvatar, instigatorAvatar, victimPlayer, instigatorPlayer)
  if IsNull(victimPlayer) then
    local friendlyFire = false
    if not IsNull(instigatorAvatar) then
      local instigatorFaction = instigatorAvatar:GetFaction()
      local victimFaction = victimAvatar:GetFaction()
      friendlyFire = instigatorFaction == victimFaction
    end
    if not IsCivilian(victimAvatar) and not friendlyFire then
      local gameState = GetGameState()
      local enemyKills = gameState:IncVariable(enemyKillsSymbol, 1)
      CheckEndGameConditions(mpRules, enemyKills)
    end
  end
end
function OnTimeLimitExpired(mpRules)
end
function OnRoundStarted(mpRules)
  if mainObjective ~= emptyTag then
    mainObjectiveAddDelay = mainObjectiveDelay
  end
end
