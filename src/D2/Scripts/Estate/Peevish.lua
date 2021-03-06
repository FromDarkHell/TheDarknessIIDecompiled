darklingSpawnControllers = {
  Instance()
}
darklingSpawnPointType = Type()
peevishAvatarType = Type()
darklingAvatarType = Type()
spawnEffectType = Type()
peevishLightType = Type()
peevishLightColor = {
  Color()
}
DamageFXStageOne = Type()
DamageFXStageTwo = Type()
DamageFXStageThree = Type()
darklingAgentSpawner = Instance()
peevishSpawnDarklingAnim = Resource()
peevishSpawnSound = Resource()
spawnAnim = Resource()
hudMovie = Resource()
fightCheckPoint = Instance()
darklingCountFirstWave = 1
darklingCountSecondwave = 2
darklingCountThirdwave = 3
darklingTimeFirstWave = 7
darklingTimeSecondWave = 10
darklingTimeThirdWave = 8
harvestDarknessContextAction = Instance()
objectiveHintType = Type()
local spawnDarklings = true
local UpdateHealthBar = function(avatar)
  if IsNull(_T.gHudMovieInstance) then
    _T.gHudMovieInstance = gFlashMgr:FindMovie(hudMovie)
  end
  local healthPct = avatar:GetHealth() / avatar:GetMaxHealth() * 100
  local args = string.format("true,%f,%s", healthPct, "Peevish")
  if IsNull(_T.gHudMovieInstance) == false then
    _T.gHudMovieInstance:Execute("SetBossHealthInfo", args)
  end
end
local RemoveHealthBar = function()
  local args = string.format("false,%f,%s", 0, "Peevish")
  _T.gHudMovieInstance:Execute("SetBossHealthInfo", args)
  _T.gHudMovieInstance = nil
end
local SpawnDarklings = function(peevish)
  local closest = 9999
  local furthest = 0
  local d = 0
  local spawner
  local playerAvatar = gRegion:GetPlayerAvatar()
  local gameDifficulty = gRegion:GetGameRules():GetCurrentDifficulty()
  if gameDifficulty ~= 0 then
    for i = 1, #darklingSpawnControllers do
      d = Distance(playerAvatar:GetPosition(), darklingSpawnControllers[i]:GetPosition())
      if furthest < d then
        spawner = darklingSpawnControllers[i]
        furthest = d
      end
    end
    spawner:FirePort("Reset")
    spawner:FirePort("Start")
    local deco = gRegion:CreateEntity(spawnEffectType, spawner:GetPosition(), spawner:GetRotation())
  end
end
local PeevishSpawnDarkling = function(peevish, darklingNum)
  local peevishAgent = peevish:GetAgent()
  if IsNull(peevishAgent) == false then
    peevishAgent:PlayPhrase(15)
  end
  for i = 1, darklingNum do
    darklingAgentSpawner:SpawnAgentNearAvatar(peevish, 3)
  end
end
local function PeevishThreshold(waveCount, waveTime, healthThreshold)
  local peevishAvatar = gRegion:FindNearest(peevishAvatarType, Vector(), INF)
  local t = 0
  while healthThreshold < peevishAvatar:GetHealth() do
    if waveTime <= t then
      PeevishSpawnDarkling(peevishAvatar, waveCount)
      t = 0
    end
    t = t + DeltaTime()
    Sleep(0)
    UpdateHealthBar(peevishAvatar)
  end
  if 0 < peevishAvatar:GetHealth() then
    SpawnDarklings(peevishAvatar)
  end
end
function LoadFromCheckpoint()
  _T.gLoadedFromCheckpoint = true
end
function Peevish()
  local playerAvatar = gRegion:GetPlayerAvatar()
  local peevishAvatar = gRegion:FindNearest(peevishAvatarType, Vector(), INF)
  local peevishAgent = peevishAvatar:GetAgent()
  local peevishDamageController = peevishAvatar:DamageControl()
  local peevishLight, peevishDamageFXOne, peevishDamageFXTwo, peevishDamageFXThree
  peevishLight = peevishAvatar:Attach(peevishLightType, Symbol(), Vector(0, 1, 0))
  peevishDamageFXOne = peevishAvatar:Attach(DamageFXStageOne, Symbol(), Vector(0, 1, 0))
  peevishDamageFXTwo = peevishAvatar:Attach(DamageFXStageTwo, Symbol(), Vector(0, 1, 0))
  peevishDamageFXThree = peevishAvatar:Attach(DamageFXStageThree, Symbol(), Vector(0, 1, 0))
  if not _T.gLoadedFromCheckpoint then
    peevishLight:SetBrightness(5)
    if IsNull(spawnAnim) == false then
      peevishAvatar:PlayAnimation(spawnAnim, true)
    end
    peevishAvatar:PushOtherControllers(true)
    peevishLight:SetColor(peevishLightColor[1])
    peevishDamageFXOne:Enable()
    PeevishThreshold(darklingCountFirstWave, darklingTimeFirstWave, 1450)
    peevishLight:SetColor(peevishLightColor[2])
    peevishDamageFXOne:Destroy()
    peevishDamageFXTwo:Enable()
    PeevishThreshold(darklingCountSecondwave, darklingTimeSecondWave, 900)
    fightCheckPoint:FirePort("Save")
  else
    peevishAvatar:SetHealth(900)
  end
  peevishLight:SetColor(peevishLightColor[3])
  peevishDamageFXTwo:Destroy()
  peevishDamageFXThree:Enable()
  PeevishThreshold(darklingCountThirdwave, darklingTimeThirdWave, 400)
  local peevishDeathPosition = peevishLight:GetPosition()
  while 0 < peevishAvatar:GetHealth() do
    UpdateHealthBar(peevishAvatar)
    peevishDeathPosition = peevishAvatar:GetPosition()
    Sleep(0)
  end
  if IsNull(peevishAgent) == false then
    peevishAgent:SetBlockVoiceBarks(true, Engine.BLOCK_SOLO)
  end
  RemoveHealthBar()
  peevishDamageFXThree:Destroy()
  peevishLight:Destroy()
  local darklings = gRegion:FindAll(darklingAvatarType, playerAvatar:GetPosition(), 0, 200)
  if IsNull(darklings) == false then
    for i = 1, #darklings do
      darklings[i]:Destroy()
    end
  end
  if IsNull(harvestDarknessContextAction) == false then
    Sleep(3)
    harvestDarknessContextAction:FirePort("Enable")
    harvestDarknessContextAction:SetPosition(peevishDeathPosition)
  end
  local objective = Symbol("/D2/Language/SPGame/EstateObjHarvestDarkness")
  local objhint = gRegion:CreateEntity(objectiveHintType, peevishDeathPosition, Rotation())
  local player = playerAvatar:GetPlayer()
  local teamId = player:GetTeam()
  local gameState = gRegion:GetGameRules():GetGameState(teamId)
  gameState:AddObjective(objective, objhint)
end
