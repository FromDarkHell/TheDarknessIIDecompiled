darklingJackieVoScriptTrigger = Instance()
darklingTankSpawnScriptTrigger = Instance()
darklingTankSpawnStopScriptTrigger = Instance()
darklingInterestActionScriptTrigger = Instance()
swiftyObjectiveScriptTrigger = Instance()
arenaCheckpointMidScript = Instance()
arenaCheckpointEnd = Instance()
waveSpawnController = {
  Instance()
}
reinforcementSpawnController = {
  Instance()
}
waveBarks = {
  Resource()
}
reinforcementBarks = {
  Resource()
}
barkDelay = 1.5
darklingHidingPlaceA = Instance()
darklingHidingPlaceB = Instance()
darklingTankSpawnA = Instance()
darklingTankSpawnB = Instance()
darklingCraneWaypoint = Instance()
darklingAvatarType = Type()
leftDarklingTrigger = Instance()
rightDarklingTrigger = Instance()
craneLightType = Type()
craneFlareType = Type()
craneConeType = Type()
craneAvatarType = Type()
craneSwingDelay = {
  4,
  4,
  4,
  6
}
fasterSwingDelay = {
  2,
  2,
  2,
  3
}
enableObjects = {
  Instance()
}
disableObjects = {
  Instance()
}
largeLightScript = Instance()
largeLightMesh = Instance()
debugCraneFight = false
local waveEnemyCount = {
  0,
  0,
  0,
  0
}
local waveDeathThreshold = {
  1,
  1,
  2,
  3
}
local waveFinished = {
  false,
  false,
  false,
  false
}
local currentWave = 0
local craneAvatar
_T.gSwingDelay = {
  craneSwingDelay[1],
  craneSwingDelay[2],
  craneSwingDelay[3],
  craneSwingDelay[4]
}
_T.gEnemyCount = 0
function OnPassedThrough(entity)
  if (entity == leftDarklingTrigger or entity == rightDarklingTrigger) and _T.gWave < 5 then
    darklingInterestActionScriptTrigger:FirePort("Execute")
  end
end
local MoveDarkling = function(destination, align, wait)
  local avatar = gRegion:FindNearest(darklingAvatarType, Vector())
  if IsNull(avatar) == false then
    local agent = avatar:GetAgent()
    agent:MoveTo(destination, true, align, wait)
    Sleep(0)
  end
end
local SpawnTanks = function(tankSpawn)
  darklingTankSpawnScriptTrigger:FirePort("Execute")
end
local PlaySound = function(object, sound, buffer, ignoreIfBusy, interruptIfBusy)
  if interruptIfBusy then
    if not IsNull(_T.gSoundInstance) then
      _T.gSoundInstance:Stop(true)
    end
  elseif not ignoreIfBusy then
    while not IsNull(_T.gSoundInstance) and _T.gSoundInstance:IsPlaying() do
      Sleep(0)
    end
  elseif not IsNull(_T.gSoundInstance) and _T.gSoundInstance:IsPlaying() then
    return
  end
  if not IsNull(object) then
    _T.gSoundInstance = object:PlaySound(sound, false)
    while not IsNull(_T.gSoundInstance) and _T.gSoundInstance:IsPlaying() do
      Sleep(0)
    end
    Sleep(buffer)
  end
end
local function CountEnemies()
  for i = 1, #waveEnemyCount do
    waveEnemyCount[i] = 0
  end
  for j = 1, #waveSpawnController do
    if not IsNull(waveSpawnController[j]) then
      waveEnemyCount[j] = waveEnemyCount[j] + waveSpawnController[j]:GetActiveCount()
    end
    if not IsNull(reinforcementSpawnController[j]) then
      waveEnemyCount[j] = waveEnemyCount[j] + reinforcementSpawnController[j]:GetActiveCount()
    end
  end
end
local function SpawnEnemies(useReinforcements, playBarks, initialDelay, afterDelay)
  local craneAvatar = gRegion:FindNearest(craneAvatarType, Vector(), INF)
  local w = currentWave
  local enemyThreshold = 0
  CountEnemies()
  if useReinforcements then
    while enemyThreshold < waveEnemyCount[w] do
      if w < _T.gWave then
        return
      end
      CountEnemies()
      Sleep(0)
    end
  else
    while enemyThreshold < waveEnemyCount[w - 1] do
      if w < _T.gWave then
        return
      end
      CountEnemies()
      Sleep(0)
    end
  end
  if 0 < initialDelay then
    local d = 0
    while initialDelay > d do
      if _T.gWave > currentWave then
        return
      end
      if debugCraneFight == true then
        Broadcast("Enemies spawning in: " .. tostring(initialDelay - d))
      end
      d = d + 1
      Sleep(1)
    end
  end
  if useReinforcements then
    reinforcementSpawnController[w]:FirePort("Reset")
    if debugCraneFight == true then
      Broadcast("Reinforcements Spawned")
    end
  else
    waveSpawnController[w]:FirePort("Reset")
    if debugCraneFight == true then
      Broadcast("Enemies Spawned")
    end
  end
  if playBarks == true then
    Sleep(barkDelay)
    PlaySound(craneAvatar, waveBarks[w], 0, false, false)
  end
  if useReinforcements == false then
    CountEnemies()
    local count = 0
    while waveEnemyCount[w] > waveDeathThreshold[w] and afterDelay > count do
      Sleep(1)
      count = count + 1
      CountEnemies()
    end
  else
    Sleep(afterDelay)
  end
end
local function AdjustCraneSpeed()
  Sleep(2)
  CountEnemies()
  if waveEnemyCount[currentWave] < 1 then
    _T.gSwingDelay[currentWave] = fasterSwingDelay[currentWave]
  else
    _T.gSwingDelay[currentWave] = craneSwingDelay[currentWave]
  end
end
local function DebugWave()
  if debugCraneFight == true then
    Broadcast("Wave" .. currentWave)
    Broadcast(craneAvatar:GetHealth())
  end
end
local TriggerEnd = function()
  Sleep(0.5)
  for i = 1, #enableObjects do
    if not IsNull(enableObjects[i]) then
      enableObjects[i]:FirePort("Enable")
    end
  end
  for j = 1, #disableObjects do
    if not IsNull(disableObjects[j]) then
      disableObjects[j]:FirePort("Disable")
    end
  end
  Sleep(3)
  largeLightScript:FirePort("Execute")
  largeLightMesh:Destroy()
  Sleep(3)
  swiftyObjectiveScriptTrigger:FirePort("Execute")
end
function TriggerEndOfFight()
  TriggerEnd()
end
function StartCraneBattle()
  craneAvatar = gRegion:FindNearest(craneAvatarType, Vector(), INF)
  ObjectPortHandler(leftDarklingTrigger, "OnPassedThrough")
  ObjectPortHandler(rightDarklingTrigger, "OnPassedThrough")
  if IsNull(_T.gCheckpointLoaded) then
    _T.gCheckpointLoaded = false
  end
  if IsNull(reinforcementSpawnController) or IsNull(fasterSwingDelay) or IsNull(craneSwingDelay) then
  end
  while _T.gWave < 5 and not IsNull(craneAvatar) do
    if _T.gWave == 1 and waveFinished[1] == false then
      currentWave = 1
      DebugWave()
      AdjustCraneSpeed()
      Sleep(2)
      darklingJackieVoScriptTrigger:FirePort("Execute")
      Sleep(9)
      SpawnTanks(darklingTankSpawnA)
      waveFinished[1] = true
    end
    if _T.gWave == 2 and waveFinished[2] == false then
      darklingTankSpawnStopScriptTrigger:FirePort("Execute")
      currentWave = 2
      DebugWave()
      Sleep(2)
      SpawnEnemies(false, true, 0, 12)
      SpawnTanks(darklingTankSpawnA)
      waveFinished[2] = true
    end
    if _T.gWave == 3 and waveFinished[3] == false then
      darklingTankSpawnStopScriptTrigger:FirePort("Execute")
      currentWave = 3
      DebugWave()
      if _T.gCheckpointLoaded == false then
        arenaCheckpointMidScript:FirePort("Execute")
      end
      Sleep(1)
      SpawnEnemies(false, true, 0, 16)
      SpawnTanks(darklingTankSpawnB)
      waveFinished[3] = true
      SpawnEnemies(true, true, 10, 0)
    end
    if _T.gWave == 4 and waveFinished[4] == false then
      darklingTankSpawnStopScriptTrigger:FirePort("Execute")
      currentWave = 4
      DebugWave()
      Sleep(5)
      local craneLight = craneAvatar:GetAllAttachments(craneLightType)
      for i = 1, #craneLight do
        craneLight[i]:TurnOn()
      end
      local craneFlare = craneAvatar:GetAllAttachments(craneFlareType)
      for i = 1, #craneFlare do
        craneFlare[i]:FirePort("Enable")
      end
      local craneCone = craneAvatar:GetAllAttachments(craneConeType)
      for i = 1, #craneCone do
        craneCone[i]:FirePort("Show")
      end
      Sleep(2)
      SpawnEnemies(false, true, 0, 16)
      SpawnTanks(darklingTankSpawnB)
      waveFinished[4] = true
      SpawnEnemies(true, true, 10, 0)
    end
    craneAvatar = gRegion:FindNearest(craneAvatarType, Vector(), INF)
    Sleep(0)
  end
  darklingTankSpawnStopScriptTrigger:FirePort("Execute")
  arenaCheckpointEnd:FirePort("Enable")
  TriggerEnd()
end
