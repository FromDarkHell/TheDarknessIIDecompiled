assassinateTargetTag = Symbol()
numTargetsToKill = 1
endMissionFadeDuration = 4
startMissionScriptTriggerTag = Symbol()
endMissionScriptTriggerTag = Symbol()
playerJoinedScriptTriggerTag = Symbol()
startRoundScriptTriggerTag = Symbol()
volumeMixer = Resource()
missionChallengeTag = Symbol()
enemyAvatarType = Type()
local emptyTag = Symbol()
local endMissionFadeTime = 0
local endMissionTargetGainBias = -50
local numTargetsKilled = 0
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
local function CompleteChallenge()
  if missionChallengeTag == emptyTag then
    return
  end
  local humans = gRegion:GetHumanPlayers()
  for i = 1, #humans do
    gChallengeMgr:NotifyTag(humans[i], missionChallengeTag)
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
local function CheckEndGameConditions(mpRules, victimAvatar)
  local humans = gRegion:GetHumanPlayers()
  if assassinateTargetTag ~= emptyTag and victimAvatar:GetTag() == assassinateTargetTag then
    numTargetsKilled = numTargetsKilled + 1
  end
  if numTargetsKilled >= numTargetsToKill then
    if not IsNull(enemyAvatarType) then
      ForceEscape()
    end
    Sleep(7)
    CompleteChallenge()
    ExecuteScripts(endMissionScriptTriggerTag)
    mpRules:EndGame(Engine.GameRules_GS_SUCCESS, endMissionFadeDuration)
  end
end
function OnLevelLoaded(mpRules)
  ExecuteScripts(startMissionScriptTriggerTag)
end
function OnUpdate(mpRules, delta)
end
function OnPlayerConnected(mpRules, p)
  ExecuteScripts(playerJoinedScriptTriggerTag)
end
function OnDeath(mpRules, victimAvatar, instigatorAvatar, victimPlayer, instigatorPlayer)
  CheckEndGameConditions(mpRules, victimAvatar)
end
function OnTimeLimitExpired(mpRules)
end
function OnRoundStarted(mpRules)
  ExecuteScripts(startRoundScriptTriggerTag)
end
