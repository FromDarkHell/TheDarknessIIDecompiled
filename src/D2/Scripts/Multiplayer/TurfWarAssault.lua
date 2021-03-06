startMissionScriptTriggerTag = Symbol()
endMissionScriptTriggerTag = Symbol()
playerJoinedScriptTriggerTag = Symbol()
startRoundScriptTriggerTag = Symbol()
endMissionExtractionVolumeTag = Symbol()
endMissionFadeDuration = 4
mainObjective = Symbol()
mainObjectiveDelay = 0.1
local emptyTag = Symbol()
local mainObjectiveAddDelay = -1
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
function OnFull(object)
  local gameRules = gRegion:GetGameRules()
  if gameRules:IsEnding() then
    return
  end
  ExecuteScripts(endMissionScriptTriggerTag)
  if mainObjective ~= emptyTag then
    RemoveMainObjective()
  end
  Sleep(5)
  gameRules:EndGame(Engine.GameRules_GS_SUCCESS, endMissionFadeDuration)
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
end
function OnTimeLimitExpired(mpRules)
end
function OnRoundStarted(mpRules)
  if mainObjective ~= emptyTag then
    mainObjectiveAddDelay = mainObjectiveDelay
  end
  local volumes = gRegion:FindTagged(endMissionExtractionVolumeTag)
  if not IsNull(volumes) and 0 < #volumes then
    local v = volumes[1]
    ObjectPortHandler(v, "OnFull")
  end
  ExecuteScripts(startRoundScriptTriggerTag)
end
