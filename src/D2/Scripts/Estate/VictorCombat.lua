vulnerableHealth = 100
phaseStartHealth = 1000
stunHealth = 700
victorMaxHealth = 1000
healthBarMaxHealth = 2275
phaseEndHealth = 50
stunDuration = 10
darklingSummonDelay = 10
darklingSummonCount = 3
darklingSummonCountDiff = {
  0,
  3,
  7,
  7,
  10,
  10
}
darklingSummonIntervalDelay = 1
VictorDefendTime = 5
numResWaves = 0
numResAgents = {4}
healthGain = 100
damageCheckTime = 5
waveDelay = 5
victorHideTime = 8
summonStaggerDelay = 7
SummonStaggerCount = 3
summonTrickleDelay = 2
SummonReinforceCount = 3
maxResAgents = 4
resBufferDelay = 10
lastPhase = false
pause = false
debugMode = false
essence = 0
victorResAnim = Resource()
darklingSummonAnim = Resource()
resSpawnAnim = Resource()
hudMovie = WeakResource()
stunAnim = Resource()
getUpAnim = Resource()
victorBark = Resource()
endCinematic = Instance()
victorSpawn = Instance()
proximityTrigger = Instance()
hideWaypointTag = Symbol()
returnFromHideWaypointTag = Symbol()
resSpawnControllers = {
  Instance()
}
victorResWaypoints = {
  Instance()
}
victorDarklingSpawnPoints = {
  Instance()
}
darklingAgentSpawner = Instance()
darknessDrainEntity = Type()
darklingSpawnController = {
  Instance()
}
resWaypoints = {
  Instance()
}
resAgentType = {
  Type()
}
victorAvatarType = Type()
resSpawnPoints1Tag = Symbol()
resSpawnPoints2Tag = Symbol()
spawnEffectType = Type()
hideWaypoint = Instance()
victorAppearWaypoint = Instance()
shieldSpawn = {
  Instance()
}
bossLightTrigger = Instance()
victorGunLight = Type()
shieldAvatarType = Type()
spawnPoint = Instance()
deathWaypoint = Instance()
fallDownAnim = Resource()
idleAnim = Resource()
yOffset = 3
hitProxyType = Type()
sequencerDuration = 3
object = Instance()
port = String()
_T.gPrevHealthPct = 0
_T.gMinHealth = 150
local UpdateHealthBar = function(avatar)
  if IsNull(_T.gMovieInstance) then
    _T.gMovieInstance = gFlashMgr:FindMovie(hudMovie)
  end
  _T.gPreviousHealth = stunHealth
  local healthPct = (avatar:GetHealth() - _T.gMinHealth) / (healthBarMaxHealth - _T.gMinHealth) * 100
  if healthPct ~= _T.gPrevHealthPct then
    local args = string.format("true,%f,%s", healthPct, "Victor")
    if IsNull(_T.gMovieInstance) then
      return
    end
    _T.gMovieInstance:Execute("SetBossHealthInfo", args)
    _T.gPrevHealthPct = healthPct
  end
end
local ShutdownHealthBar = function()
  local args = string.format("false,%f,%s", 0, "Victor")
  _T.gMovieInstance:Execute("SetBossHealthInfo", args)
  _T.gMovieInstance = nil
end
function PlaySpawnAnim(entity)
  local agent = entity:GetAgent()
  agent:PlayAnimation(resSpawnAnim, true)
  if not IsNull(agent) then
    agent:StopScriptedMode()
  end
end
function PlayDialogTest()
  local hitProxy
  local avatar = gRegion:FindNearest(victorAvatarType, Vector(), INF)
  local temp = object
  local temp2 = port
  hitProxy = avatar:GetAttachment(hitProxyType)
  ObjectPortHandler(hitProxy, "OnDamaged")
end
function OnDamaged(entity)
  local avatar = gRegion:FindNearest(victorAvatarType, Vector(), INF)
  object:FirePort(port)
end
function PlayResAnim(entity)
  local agent = entity:GetAgent()
  local lookTriggers = gRegion:FindTagged(Symbol("VictorResInterrupt"))
  if Distance(lookTriggers[1]:GetPosition(), entity:GetPosition()) < Distance(lookTriggers[2]:GetPosition(), entity:GetPosition()) then
    lookTriggers[1]:FirePort("Enable")
  else
    lookTriggers[2]:FirePort("Enable")
  end
  Sleep(0)
  agent:PlaySpeech(victorBark, false)
  agent:PlayAnimation(victorResAnim, true)
  agent:StopScriptedMode()
  hideWaypoint:FirePort("Enable")
  lookTriggers[1]:FirePort("Disable")
  lookTriggers[2]:FirePort("Disable")
  if IsNull(agent) then
    entity:Destroy()
  end
end
function InterruptResAnim()
  local avatar = gRegion:FindNearest(victorAvatarType, Vector(), INF)
  local agent = avatar:GetAgent()
  agent:StopScriptedMode()
  hideWaypoint:FirePort("Enable")
end
function UpdateHPBarLoop()
  local victor = gRegion:FindNearest(victorAvatarType, Vector(), INF)
  _T.gUpdateHPBar = true
  while _T.gUpdateHPBar do
    if not IsNull(victor) then
      UpdateHealthBar(victor)
      if not IsNull(spawnPoint) then
        spawnPoint:SetPosition(victor:GetSimPosition())
        spawnPoint:SetRotation(victor:GetRotation())
      end
    elseif not _T.gPauseHPBar then
      victor = gRegion:FindNearest(victorAvatarType, Vector(), INF)
    end
    Sleep(0)
  end
  ShutdownHealthBar()
end
function StopHPBar()
  _T.gUpdateHPBar = false
end
function SetHealth()
  local victor = gRegion:FindNearest(victorAvatarType, Vector(), INF)
  while IsNull(victor) do
    victor = gRegion:FindNearest(victorAvatarType, Vector(), INF)
    Sleep(0)
  end
  victor:SetHealth(phaseStartHealth)
end
function BehaviourStopped()
  _T.gVictorBehaviourStopped = true
end
function BehaviourStarted()
  _T.gVictorBehaviourStopped = false
end
local SpawnEnemies = function(victor, victorAgent)
  local player = gRegion:GetPlayerAvatar()
  local farthestIndex, agent, spawnPoints
  local spawnEffects = {}
  local agentTypes = {}
  local effect, shieldAvatars
  local shieldAgentCount = 0
  for i = 1, numResWaves do
    if 1 < #resSpawnControllers and Distance(resSpawnControllers[1]:GetPosition(), player:GetPosition()) <= Distance(resSpawnControllers[2]:GetPosition(), player:GetPosition()) then
      farthestIndex = 2
      spawnPoints = gRegion:FindTagged(resSpawnPoints2Tag)
    else
      farthestIndex = 1
      spawnPoints = gRegion:FindTagged(resSpawnPoints1Tag)
    end
    hideWaypoint:FirePort("Disable")
    victorResWaypoints[farthestIndex]:FirePort("Enable")
    victorAgent:StopScriptedMode()
    while Distance(victor:GetPosition(), victorResWaypoints[farthestIndex]:GetPosition()) > 3 do
      Sleep(0)
    end
    victor:ScriptRunChildScript(Symbol("PlayResAnim"), false)
    victorResWaypoints[farthestIndex]:FirePort("Disable")
    for k = 1, #spawnPoints do
      effect = gRegion:CreateEntity(spawnEffectType, spawnPoints[k]:GetPosition(), Rotation())
      table.insert(spawnEffects, 1, effect)
    end
    effect = gRegion:CreateEntity(spawnEffectType, shieldSpawn[farthestIndex]:GetPosition(), Rotation())
    table.insert(spawnEffects, 1, effect)
    shieldSpawn[farthestIndex]:FirePort("Reset")
    for k = 1, numResAgents[i] do
      if #agentTypes == 0 then
        for j = 1, #resAgentType do
          table.insert(agentTypes, j, resAgentType[j])
        end
      end
      resSpawnControllers[farthestIndex]:ScriptedSetAgentType(agentTypes[1])
      table.remove(agentTypes, 1)
      agent = resSpawnControllers[farthestIndex]:SpawnAgent()
      agent:SetAllExits(false)
      while resSpawnControllers[farthestIndex]:GetActiveCount() >= maxResAgents do
        Sleep(0)
      end
      if k == SummonStaggerCount then
        Sleep(summonStaggerDelay)
      elseif k > SummonStaggerCount then
        Sleep(summonTrickleDelay)
      end
    end
    for k = 1, #spawnEffects do
      spawnEffects[k]:FirePort("Destroy")
    end
    for k = 1, #spawnPoints + #shieldSpawn do
      table.remove(spawnEffects, 1)
    end
    shieldAvatars = gRegion:FindAll(shieldAvatarType, Vector(), 0, INF)
    while 0 < resSpawnControllers[farthestIndex]:GetActiveCount() or not IsNull(shieldAvatars) do
      Sleep(0.1)
      shieldAvatars = gRegion:FindAll(shieldAvatarType, Vector(), 0, INF)
    end
    Sleep(waveDelay)
  end
end
function StartPhase()
  local health
  local timeElapsed = 0
  local carriedEntity
  local phaseEnded = false
  local farthestIndex, darknessDrain, newVictor
  local victor = gRegion:FindNearest(victorAvatarType, Vector(), INF)
  local diff = gRegion:GetGameRules():GetCurrentDifficulty()
  local debugVar = darklingSummonCount
  while IsNull(victor) do
    Sleep(0.1)
    victor = gRegion:FindNearest(victorAvatarType, Vector(), INF)
  end
  local victorAgent = victor:GetAgent()
  local player = gRegion:GetPlayerAvatar()
  local inventory = player:ScriptInventoryControl()
  health = victor:GetHealth()
  if not IsNull(bossLightTrigger) then
    bossLightTrigger:FirePort("Execute")
    gRegion:FindNearest(victorGunLight, Vector(), INF):Destroy()
  end
  if not IsNull(victorAppearWaypoint) then
    Sleep(3)
    hideWaypoint:FirePort("Disable")
    victorAppearWaypoint:FirePort("Enable")
    Sleep(1)
    victorAppearWaypoint:FirePort("Disable")
    victorAgent:PlayPhrase(13)
  end
  _T.gTriggerEntered = false
  _T.gVictorBehaviourStopped = false
  if 0 < numResWaves then
    SpawnEnemies(victor, victorAgent)
  end
  health = victor:GetHealth()
  if not IsNull(proximityTrigger) then
    ObjectPortHandler(proximityTrigger, "OnTouched")
  end
  if debugMode then
    timeElapsed = darklingSummonDelay
  end
  hideWaypoint:FirePort("Disable")
  while health > stunHealth and not _T.gTriggerEntered and numResWaves == 0 do
    timeElapsed = timeElapsed + DeltaTime()
    if 1 < #darklingSpawnController and timeElapsed > darklingSummonDelay then
      if darklingSpawnController[1]:IsEnabled() then
        farthestIndex = 1
      else
        farthestIndex = 2
      end
      victorDarklingSpawnPoints[farthestIndex]:FirePort("Enable")
      victorAgent:SetDesiredWaypoint(victorDarklingSpawnPoints[farthestIndex])
      victorAgent:PlayPhrase(13)
      if not IsNull(victor) then
        Sleep(1)
      else
        return
      end
      timeElapsed = 0
      for i = 1, darklingSummonCountDiff[diff + 1] do
        if not IsNull(victor) then
          darklingSpawnController[farthestIndex]:SpawnAgent()
        else
          return
        end
        Sleep(darklingSummonIntervalDelay)
        if i == 4 then
          victorDarklingSpawnPoints[farthestIndex]:FirePort("Disable")
          victorAgent:SetDesiredWaypoint(hideWaypoint)
          victor:Teleport(hideWaypoint:GetPosition())
          victorAgent:MoveTo(hideWaypoint, true, true, true)
          victor:SetHidden(true)
          victorAgent:ReturnToAiControl()
        end
      end
      Sleep(5)
      victorAgent:SetDesiredWaypoint(victorDarklingSpawnPoints[farthestIndex])
      victorDarklingSpawnPoints[farthestIndex]:FirePort("Disable")
      victor:Teleport(victorDarklingSpawnPoints[farthestIndex]:GetPosition())
      victorAgent:MoveTo(hideWaypoint, true, true, false)
      victorAgent:ClearDesiredPosition()
      victorAgent:StopScriptedMode()
    end
    health = victor:GetHealth()
    Sleep(0)
  end
  if not IsNull(victor) then
    if not IsNull(darknessDrainEntity) then
      darknessDrain = gRegion:FindNearest(darknessDrainEntity, Vector(), INF)
      while not IsNull(darknessDrain) do
        Sleep(0)
        darknessDrain = gRegion:FindNearest(darknessDrainEntity, Vector(), INF)
      end
    end
    victor:Destroy()
  end
  if not lastPhase then
    newVictor = victorSpawn:SpawnAgent()
    newVictor:GetAvatar():SetHealth(health)
    newVictor:MoveTo(hideWaypoint, false, false, true)
    hideWaypoint:FirePort("Enable")
    newVictor:GetAvatar():SetHidden(true)
    newVictor:ReturnToAiControl()
  else
    local boss = gRegion:FindNearest(victorAvatarType, Vector(), INF)
    _T.gPauseHPBar = true
    if not IsNull(boss) then
      boss:Destroy()
    end
    local deadVictor = spawnPoint:SpawnAgent()
    local damageController = deadVictor:GetAvatar():DamageControl()
    damageController:SetDamageMultiplier(0)
    Sleep(0.1)
    deadVictor:PlayPhrase(21)
    deadVictor:MoveTo(deathWaypoint, false, false, true)
    deadVictor:ReturnToAiControl()
    damageController:SetDamageMultiplier(1)
    local bossAvatar = deadVictor:GetAvatar()
    _T.gPauseHPBar = false
    local currentHealth = bossAvatar:GetHealth()
    while 150 < currentHealth do
      currentHealth = bossAvatar:GetHealth()
      Sleep(0)
    end
    _T.gUpdateHPBar = false
    endCinematic:FirePort("StartPlaying")
    deadVictor:GetAvatar():Destroy()
    inventory:GiveXP(essence)
  end
end
function OnTouched(entity)
  Sleep(1)
  _T.gTriggerEntered = true
end
