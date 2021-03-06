waveHealthThresholds = {
  600,
  400,
  200
}
destroyBuildingCin = Instance()
stuckInBuildingCin = Instance()
waypoint = Instance()
recoverFromBuildingCin = Instance()
idleCin = Instance()
craneStartSwingDelay = 5
toggleTankSpawn = Instance()
waitForBuildingSmash = true
cameraShakeTrigger = Instance()
doubleVisionTrigger = Instance()
craneDamagedSkel = Instance()
craneDamagedDeco = Instance()
introCinematic = Instance()
numWaves = 3
numSwingsBeforeDestroyBuilding = 1
craneMaxHealth = 800
tankDamage = 200
swiftyAttackWarningTrigger = Instance()
swiftySkel = Instance()
swiftyDamagedTrigger = Instance()
corners = {
  Instance()
}
gameplayScriptTrigger = Instance()
craneScriptTrigger = Instance()
leftFarTriggers = {
  Instance()
}
rightFarTriggers = {
  Instance()
}
leftMidTriggers = {
  Instance()
}
rightMidTriggers = {
  Instance()
}
leftNearTriggers = {
  Instance()
}
rightNearTriggers = {
  Instance()
}
craneHitProxyType = Type()
craneBodyHitProxyType = Type()
craneDamageTriggerType = Type()
wreckingBallHitProxyType = Type()
wreckingBallDamageVolumeType = Type()
wreckingBallDamageVolumeJackieType = Type()
wreckingBallDamageVolumePillarType = Type()
stageOneDamageEffects = Type()
stageTwoDamageEffects = Type()
damagedEffects = Type()
damagedEffectsBone = Symbol()
craneFinalDestroyedFx = Instance()
craneAvatarType = Type()
swiftySkelType = Type()
bossRecordType = Type()
craneToppleAnim = Resource()
craneToppleIdleAnim = Resource()
swiftyLoopAnim = Resource()
swiftyDialog = {
  Resource()
}
wreckingBallSwingSound = Resource()
wreckingBallImpactSound = Resource()
swiftyAttackWarning = {
  Resource()
}
swiftyAttackSuccess = {
  Resource()
}
swiftyStuck = {
  Resource()
}
swiftyDamaged = {
  Resource()
}
darklingPraise = {
  Resource()
}
swiftyUnstuck = Resource()
swiftyEscape = {
  Resource()
}
darklingNoticeSwiftyEscape = {
  Resource()
}
SwiftyOutOfCraneAnim = Resource()
tauntAnim = Resource()
JackieShootCraneAudio = {
  Resource()
}
destroyWallWave = 2
hudMovie = WeakResource()
wreckingBallImpactRingingSound = Resource()
swingLeftFarAnim = Resource()
swingRightFarAnim = Resource()
swingLeftMidAnim = Resource()
swingRightMidAnim = Resource()
swingLeftNearAnim = Resource()
swingRightNearAnim = Resource()
leftWindup = Resource()
rightWindup = Resource()
leftFail = Resource()
rightFail = Resource()
local movieInstance
local prevHealthPct = 0
local minHealth = 200
local cranePrevHealth = craneMaxHealth
local consecutiveHits = 0
local craneAvatar, craneAgent
local healthPct = 100
local damageDifference, bossRecord
local LEFT = 1
local RIGHT = 2
local FAR = 1
local MID = 2
local NEAR = 3
local function InitHealthBar()
  movieInstance = gFlashMgr:FindMovie(hudMovie)
end
local function UpdateHealthBar()
  local curHealth = craneAvatar:GetHealth()
  healthPct = curHealth / craneMaxHealth * 100
  damageDifference = cranePrevHealth - curHealth
  cranePrevHealth = curHealth
  if 50 < damageDifference then
    if _T.gWave > 1 and damageDifference ~= craneMaxHealth - waveHealthThresholds[_T.gWave - 1] then
      swiftyDamagedTrigger:FirePort("Execute")
    elseif _T.gWave == 1 then
      swiftyDamagedTrigger:FirePort("Execute")
    end
  end
  if healthPct ~= prevHealthPct then
    local args = string.format("true,%f,%s", healthPct, "Swifty")
    movieInstance:Execute("SetBossHealthInfo", args)
    prevHealthPct = healthPct
    if not IsNull(bossRecord) then
      bossRecord:SetHealth(curHealth)
    end
  end
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
local function ShutdownHealthBar()
  local args = string.format("false,%f,%s", 0, "Swifty")
  movieInstance:Execute("SetBossHealthInfo", args)
  movieInstance = nil
end
function FromCheckpoint()
  _T.gCheckpointLoaded = true
  craneScriptTrigger:FirePort("Execute")
  Sleep(1)
  gameplayScriptTrigger:FirePort("Execute")
end
function DetachSwifty()
  swiftySkel:Unattach()
end
function playSwiftyIntro()
  for i = 1, #swiftyDialog do
    swiftySkel:PlaySound(swiftyDialog[i], true)
  end
end
function swiftyExitCrane()
  Sleep(2)
  if not IsNull(SwiftyOutOfCraneAnim) then
    _T.gSwiftyEscapeSkel:PlayAnimation(SwiftyOutOfCraneAnim, true)
  end
  _T.gSwiftyEscapeSkel:FirePort("Hide")
end
function playHitSwiftySuccess()
  Sleep(0.5)
  PlaySound(swiftySkel, swiftyDamaged[math.random(1, #swiftyDamaged)], 0, false, true)
  PlaySound(_T.gDarklingAvatar, darklingPraise[math.random(1, #darklingPraise)], 0, true, false)
end
function SwiftyStuckAudio(swiftySkel)
  PlaySound(swiftySkel, swiftyStuck[1], 0, true, false)
  while not stuckInBuildingCin:IsPlaying() do
    Sleep(5)
    PlaySound(swiftySkel, swiftyStuck[math.random(2, #swiftyStuck)], 0, true, false)
  end
end
function SwiftyUnstuckAudio()
  Sleep(4)
  if IsNull(_T.gSwiftyEscapeSkel) then
    PlaySound(swiftySkel, swiftyUnstuck, 0, false, false)
  end
end
function SwiftySwingAudio()
  PlaySound(swiftySkel, swiftyAttackWarning[math.random(1, #swiftyAttackWarning)], 0, true, false)
end
function playWreckingBallSwipe(proxy)
  Sleep(0.8)
  proxy:PlaySound(wreckingBallSwingSound, false)
end
local function Initialize()
  if IsNull(_T.gCheckpointLoaded) then
    _T.gCheckpointLoaded = false
  end
  while IsNull(craneAvatar) do
    craneAvatar = gRegion:FindNearest(craneAvatarType, Vector(), INF)
    Sleep(0)
  end
  local bossRecordArray = gRegion:FindAllObjects(bossRecordType)
  if IsNull(bossRecordArray) or #bossRecordArray == 0 then
    bossRecord = gRegion:CreateObject(bossRecordType)
    bossRecord:SetHealth(craneAvatar:GetHealth())
  end
  craneAvatar:SetAnimateMaster(true)
  craneAgent = craneAvatar:GetAgent()
  craneAvatar:SetCorners(corners[1], corners[2])
  _T.gRegionsOccupied = {}
  _T.gPlayerDroppedDown = false
  local wreckingBallHitProxy, wreckingBallDamageVolume, wreckingBallDamageVolumeJackie, wreckingBallDamageVolumePillar
  wreckingBallHitProxy = craneAvatar:GetAttachment(wreckingBallHitProxyType)
  wreckingBallDamageVolume = craneAvatar:GetAttachment(wreckingBallDamageVolumeType)
  wreckingBallDamageVolumeJackie = craneAvatar:GetAttachment(wreckingBallDamageVolumeJackieType)
  wreckingBallDamageVolumePillar = craneAvatar:GetAttachment(wreckingBallDamageVolumePillarType)
  ObjectPortHandler(wreckingBallDamageVolume, "OnTouched")
  ObjectPortHandler(wreckingBallDamageVolumeJackie, "OnTouched")
  ObjectPortHandler(wreckingBallDamageVolumePillar, "OnTouched")
  _T.gCraneHitProxy = craneAvatar:GetAttachment(craneHitProxyType)
  _T.gCraneBodyHitProxies = craneAvatar:GetAllAttachments(craneBodyHitProxyType)
  _T.gCraneDamaged = false
  _T.gHoldingTank = false
  _T.gCraneDead = false
  _T.gFirstSwing = true
  _T.gWave = 1
  _T.gCraneAnimPlaying = false
  _T.gCraneState = "Idle"
  _T.gFreeCrane = false
  _T.gCraneHitBuilding = false
  _T.gBarkPlaying = false
  _T.gAnimTable = {
    {
      swingLeftFarAnim,
      swingLeftMidAnim,
      swingLeftNearAnim
    },
    {
      swingRightFarAnim,
      swingRightMidAnim,
      swingRightNearAnim
    }
  }
  _T.gSide = LEFT
  _T.gDist = FAR
  local triggerCount = 1
  _T.gTriggers = {}
  for i = 1, #leftFarTriggers do
    _T.gTriggers[triggerCount] = {
      trigger = leftFarTriggers[i],
      side = LEFT,
      dist = FAR
    }
    triggerCount = triggerCount + 1
  end
  for i = 1, #rightFarTriggers do
    _T.gTriggers[triggerCount] = {
      trigger = rightFarTriggers[i],
      side = RIGHT,
      dist = FAR
    }
    triggerCount = triggerCount + 1
  end
  for i = 1, #leftMidTriggers do
    _T.gTriggers[triggerCount] = {
      trigger = leftMidTriggers[i],
      side = LEFT,
      dist = MID
    }
    triggerCount = triggerCount + 1
  end
  for i = 1, #rightMidTriggers do
    _T.gTriggers[triggerCount] = {
      trigger = rightMidTriggers[i],
      side = RIGHT,
      dist = MID
    }
    triggerCount = triggerCount + 1
  end
  for i = 1, #leftNearTriggers do
    _T.gTriggers[triggerCount] = {
      trigger = leftNearTriggers[i],
      side = LEFT,
      dist = NEAR
    }
    triggerCount = triggerCount + 1
  end
  for i = 1, #rightNearTriggers do
    _T.gTriggers[triggerCount] = {
      trigger = rightNearTriggers[i],
      side = RIGHT,
      dist = NEAR
    }
    triggerCount = triggerCount + 1
  end
  for i = 1, #_T.gTriggers do
    ObjectPortHandler(_T.gTriggers[i].trigger, "OnTouched")
    ObjectPortHandler(_T.gTriggers[i].trigger, "OnUntouched")
  end
  if _T.gCheckpointLoaded then
    _T.gWave = 3
    _T.gCraneHitBuilding = true
    _T.gFirstSwing = false
  end
  local bossRecords = gRegion:FindAllObjects(bossRecordType)
  if not IsNull(bossRecords) and 1 <= #bossRecords then
    if 2 <= #bossRecords then
      print("More than one BossRecord in the level! How did this happen?!")
    end
    bossRecord = bossRecords[1]
    craneAvatar:SetHealth(bossRecord:GetHealth())
  else
    craneAvatar:SetHealth(450)
  end
  while introCinematic:IsPlaying() do
    Sleep(0)
  end
  InitHealthBar()
  UpdateHealthBar()
end
local function CraneDamaged()
  if craneAvatar:GetHealth() <= waveHealthThresholds[_T.gWave] then
    if _T.gWave == 2 then
      craneDamagedSkel:Attach(stageOneDamageEffects, damagedEffectsBone, Vector(-1.3, -1, 0), Rotation(0, -90, 0))
    elseif _T.gWave == 3 then
      craneDamagedSkel:Attach(stageTwoDamageEffects, damagedEffectsBone, Vector(-1.3, -1, 0), Rotation(0, -90, 0))
    end
    _T.gWave = _T.gWave + 1
    return true
  end
  return false
end
function PlayFailAnim(entity)
  local agent = entity:GetAgent()
  _T.gCraneAnimPlaying = true
  if _T.gSide == LEFT then
    agent:PlayAnimation(leftFail, true, false)
  else
    agent:PlayAnimation(rightFail, true, false)
  end
  _T.gCraneState = "Idle"
  _T.gCraneAnimPlaying = false
end
function PlayWindupAnim(entity)
  local agent = entity:GetAgent()
  _T.gCraneAnimPlaying = true
  if _T.gSide == LEFT then
    agent:PlayAnimation(leftWindup, true, true)
  else
    agent:PlayAnimation(rightWindup, true, true)
  end
  _T.gCraneAnimPlaying = false
end
function PlaySwingAnim(entity)
  local agent = entity:GetAgent()
  _T.gCraneAnimPlaying = true
  entity:StartSwing(_T.gAnimTable[_T.gSide][_T.gDist], (_T.gSide - 1) * NEAR + _T.gDist, _T.gDoIK)
  agent:PlayAnimation(_T.gAnimTable[_T.gSide][_T.gDist], true)
  _T.gCraneAnimPlaying = false
end
function CraneLoop()
  Initialize()
  local timeElapsed = 0
  local swingCount = 0
  local region, damageTrigger
  local buildingDestroyed = false
  local wreckingBallHitProxy
  local stuckCounter = 0
  swiftySkel:Unattach()
  craneAvatar:AttachEntity(swiftySkel, Symbol("GAME_C1_CAB"), Vector(-1.2, 0.5, 2.2), Rotation())
  if not IsNull(_T.gCheckpointLoaded) and _T.gCheckpointLoaded then
    buildingDestroyed = true
  else
    swiftySkel:PlayAnimation(tauntAnim, false)
    swiftySkel:ScriptRunChildScript(Symbol("playSwiftyIntro"), false)
    Sleep(craneStartSwingDelay)
  end
  wreckingBallHitProxy = craneAvatar:GetAttachment(wreckingBallHitProxyType)
  swiftySkel:PlayAnimation(swiftyLoopAnim, false, true, 0)
  while IsNull(_T.gSwingDelay) do
    Sleep(0)
  end
  while _T.gWave <= numWaves and not IsNull(craneAvatar) do
    UpdateHealthBar()
    timeElapsed = timeElapsed + DeltaTime()
    if _T.gCraneState == "Idle" then
      if not _T.gCraneHitBuilding and _T.gWave == destroyWallWave then
        _T.gCraneHitBuilding = true
        swingCount = 0
      end
      if CraneDamaged() then
        timeElapsed = 0
      elseif not buildingDestroyed and _T.gCraneHitBuilding and swingCount >= numSwingsBeforeDestroyBuilding then
        _T.gCraneState = "Stuck"
        swingCount = swingCount + 1
        while _T.gCraneAnimPlaying do
          Sleep(0)
        end
        destroyBuildingCin:FirePort("PlaceGreenRoomEntities")
        destroyBuildingCin:FirePort("StartPlaying")
      elseif timeElapsed > _T.gSwingDelay[_T.gWave] then
        _T.gSide = LEFT
        _T.gDist = FAR
        for i = 1, #_T.gTriggers do
          if _T.gTriggers[i].trigger == _T.gRegionsOccupied[1] then
            _T.gSide = _T.gTriggers[i].side
            _T.gDist = _T.gTriggers[i].dist
            break
          end
        end
        if not _T.gFirstSwing then
          swiftyAttackWarningTrigger:FirePort("Execute")
        end
        _T.gFirstSwing = false
        _T.gCraneState = "WindUp"
        swingCount = swingCount + 1
        craneAvatar:ScriptRunChildScript(Symbol("PlayWindupAnim"), false)
      end
    elseif _T.gCraneState == "Stuck" then
      if not destroyBuildingCin:IsPlaying() then
        swiftySkel:ScriptRunChildScript(Symbol("SwiftyStuckAudio"), false)
        if 5 < timeElapsed then
          _T.gCraneState = "Freed"
          timeElapsed = 0
          swiftySkel:ScriptRunChildScript(Symbol("SwiftyUnstuckAudio"), false)
        end
      end
    elseif _T.gCraneState == "WindUp" then
      if _T.gCraneAnimPlaying then
        if CraneDamaged() then
          _T.gCraneState = "Interrupted"
          timeElapsed = 0
        end
      else
        _T.gCraneState = "Swinging"
        _T.gDoIK = false
        for i = 1, #_T.gTriggers do
          if _T.gTriggers[i].trigger == _T.gRegionsOccupied[1] then
            _T.gDist = _T.gTriggers[i].dist
            _T.gDoIK = true
            break
          end
        end
        craneAvatar:ScriptRunChildScript(Symbol("PlaySwingAnim"), false)
        wreckingBallHitProxy:ScriptRunChildScript(Symbol("playWreckingBallSwipe"), false)
      end
    elseif _T.gCraneState == "Swinging" then
      if not _T.gCraneAnimPlaying or CraneDamaged() then
        timeElapsed = 0
        _T.gCraneState = "Idle"
      end
    elseif _T.gCraneState == "Freed" then
      if idleCin:IsPlaying() then
        idleCin:FirePort("StopPlaying")
        recoverFromBuildingCin:FirePort("StartPlaying")
      elseif not recoverFromBuildingCin:IsPlaying() then
        _T.gCraneState = "Idle"
        buildingDestroyed = true
      end
    elseif _T.gCraneState == "Interrupted" and not _T.gCraneAnimPlaying then
      craneAvatar:ScriptRunChildScript(Symbol("PlayFailAnim"), false)
    end
    Sleep(0)
  end
  ShutdownHealthBar()
  swiftySkel:FirePort("Hide")
  if not IsNull(craneAvatar) then
    craneAvatar:Destroy()
  end
  craneDamagedSkel:FirePort("Show")
  _T.gSwiftyEscapeSkel = gRegion:CreateEntity(swiftySkelType, Vector(), Rotation())
  craneDamagedSkel:AttachEntity(_T.gSwiftyEscapeSkel, Symbol("GAME_C1_CAB"), Vector(-1.2, 0.5, 2.2), Rotation())
  _T.gSwiftyEscapeSkel:LoopAnimation(swiftyLoopAnim)
  craneFinalDestroyedFx:FirePort("Enable")
  craneDamagedSkel:Attach(damagedEffects, damagedEffectsBone)
  _T.gSwiftyEscapeSkel:ScriptRunChildScript(Symbol("swiftyExitCrane"), false)
  craneDamagedSkel:PlayAnimation(craneToppleAnim, true)
  cameraShakeTrigger:FirePort("Execute")
  Sleep(0.5)
  _T.gSwiftyEscapeSkel:Unattach()
  craneDamagedSkel:FirePort("Hide")
  craneDamagedSkel:FirePort("Destroy")
  craneDamagedDeco:FirePort("Show")
  _T.gCraneDead = true
  Sleep(0.5)
  _T.gDarklingAvatar:PlaySound(darklingNoticeSwiftyEscape[math.random(1, #darklingNoticeSwiftyEscape)], false)
end
function OnTouched(entity)
  local player = gRegion:GetPlayerAvatar()
  if entity:IsA(wreckingBallDamageVolumeType) then
    entity:PlaySound(wreckingBallImpactSound, true)
  elseif entity:IsA(wreckingBallDamageVolumeJackieType) then
    doubleVisionTrigger:FirePort("Execute")
    if player:GetHealth() <= 20 then
      player:Damage(player:GetMaxHealth())
    end
    if not IsNull(wreckingBallImpactRingingSound) then
      player:PlaySound(wreckingBallImpactRingingSound, false)
    end
    entity:PlaySound(wreckingBallImpactSound, true)
    PlaySound(swiftySkel, swiftyAttackSuccess[math.random(1, #swiftyAttackSuccess)], 0, false, false)
  elseif entity:IsA(wreckingBallDamageVolumePillarType) then
    Sleep(0)
  else
    table.insert(_T.gRegionsOccupied, 1, entity)
  end
end
function OnUntouched(entity)
  for i = 1, #_T.gRegionsOccupied do
    if _T.gRegionsOccupied[i] == entity then
      table.remove(_T.gRegionsOccupied, i)
      break
    end
  end
end
function TriggerHitBuilding()
  _T.gCraneHitBuilding = true
end
function TriggerFreeFromBuilding()
  _T.gFreeCrane = true
end
