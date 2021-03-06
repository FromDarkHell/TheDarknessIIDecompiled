totalEnemies = 15
endMissionFadeDuration = 4
startMissionScriptTriggerTag = Symbol()
endMissionScriptTriggerTag = Symbol()
playerJoinedScriptTriggerTag = Symbol()
mainObjective = Symbol()
mainObjectiveDelay = 0.1
local emptyTag = Symbol()
local enemyKills = 0
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
local function ResetKills()
  enemyKills = 0
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
local function CheckEndGameConditions(mpRules)
  local enemiesLeft = totalEnemies - enemyKills
  print("Enemies left: " .. tostring(enemiesLeft))
  if enemiesLeft == 0 then
    Broadcast("Script for mission complete playing")
    ExecuteScripts(endMissionScriptTriggerTag)
    if mainObjective ~= emptyTag then
      RemoveMainObjective()
    end
    Sleep(5)
    mpRules:EndGame(Engine.GameRules_GS_SUCCESS, endMissionFadeDuration)
  end
end
function OnLevelLoaded(mpRules)
  ExecuteScripts(startMissionScriptTriggerTag)
  Broadcast("Script for level start playing")
  ResetKills()
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
  print("OnDeath")
  if IsNull(victimPlayer) then
    local friendlyFire = false
    if not IsNull(instigatorAvatar) then
      local instigatorFaction = instigatorAvatar:GetFaction()
      local victimFaction = victimAvatar:GetFaction()
      friendlyFire = instigatorFaction == victimFaction
    end
    if not friendlyFire then
      enemyKills = enemyKills + 1
      CheckEndGameConditions(mpRules)
    else
      print("Friendly fire")
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
