tankSpawnDelay = 5
maxTossDistance = 50
distanceFromCrane = 10
delayBeforeTankCallout = 2.5
maxTanks = 2
toggleTankSpawn = Instance()
spawnTanks = true
introCinematic = Instance()
tankSearchWaypoint = Instance()
tankSearchWaypointMirror = Instance()
darklingCarryAction = Instance()
darklingCarryActionMirror = Instance()
darklingAvatarType = Type()
tankSpawnerType = Type()
tankType = Type()
darklingCarryAnim = Resource()
darklingCarryMirrorAnim = Resource()
darklingCarryIdleAnim = Resource()
darklingCarryIdleMirrorAnim = Resource()
darklingTankCallout = {
  Resource()
}
darklingReturnToIdleAnim = Resource()
darklingSuggestTankThrow = {
  Resource()
}
swiftyDamaged = {
  Resource()
}
darklingPraise = {
  Resource()
}
playerMissedAudio = {
  Resource()
}
jackieVO = Resource()
local mDarklingAgent
local darklingCarryActionUsed = false
local darklingCarryActionMirrorUsed = false
function playHitSwiftySuccess()
  Sleep(0.5)
  _T.gSwifty:PlaySound(swiftyDamaged[_T.gSwiftyDamagedCounter], true)
  _T.gSwiftyDamagedCounter = _T.gSwiftyDamagedCounter + 1
  _T.gDarklingAvatar:PlaySound(darklingPraise[math.random(1, #darklingPraise)], false)
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
local CleanUpTanks = function(limit)
  local tankSearchRadius = 5
  local player = gRegion:GetPlayerAvatar()
  local playerTank = gRegion:FindNearest(tankType, player:GetPosition(), INF)
  local tankList = gRegion:FindAll(tankType, Vector(), 0, INF)
  local visibleTanks = {}
  if not IsNull(tankList) then
    for i = 1, #tankList do
      if tankList[i]:IsVisible() then
        table.insert(visibleTanks, tankList[i])
      end
    end
    if limit < #visibleTanks then
      for i = 1, #visibleTanks do
        if visibleTanks[i] ~= playerTank then
          visibleTanks[i]:SetVisibility(false)
          return
        end
      end
    end
  end
end
function SetSpawnTanks()
  _T.gGenerateTanks = spawnTanks
end
local function UpdateDarkling()
  if IsNull(_T.gDarklingAvatar) then
    while IsNull(_T.gDarklingAvatar) do
      _T.gDarklingAvatar = gRegion:FindNearest(darklingAvatarType, Vector(), INF)
      Sleep(0)
    end
    _T.gDarklingAvatar:DamageControl():SetDamageMultiplier(0)
    mDarklingAgent = _T.gDarklingAvatar:GetAgent()
    mDarklingAgent:SetAllExits(false)
    return true
  end
  return false
end
function OnActivated(entity)
  if entity == darklingCarryAction then
    darklingCarryActionUsed = true
  elseif entity == darklingCarryActionMirror then
    darklingCarryActionMirrorUsed = true
  end
end
function TankLoop()
  while introCinematic:IsPlaying() do
    Sleep(0)
  end
  local timeElapsed = 0
  local tank
  local firstTank = true
  local damageController, closestTankSearchWaypoint
  darklingCarryActionUsed = false
  darklingCarryActionMirrorUsed = false
  _T.gPlayerGrabbedTank = false
  _T.gGenerateTanks = false
  ObjectPortHandler(darklingCarryAction, "OnActivated")
  ObjectPortHandler(darklingCarryActionMirror, "OnActivated")
  if IsNull(_T.gCheckpointLoaded) then
    _T.gCheckpointLoaded = false
  end
  if _T.gCheckpointLoaded then
    firstTank = false
    if IsNull(_T.gWave) then
      _T.gWave = 3
    end
  elseif IsNull(_T.gWave) then
    _T.gWave = 1
  end
  while not _T.gCraneDead do
    UpdateDarkling()
    local wave = _T.gWave
    local player = gRegion:GetPlayerAvatar()
    if wave < 5 then
      if wave < 3 then
        mDarklingAgent:MoveTo(tankSearchWaypointMirror, true, true, true)
        while not _T.gGenerateTanks do
          Sleep(0)
          if UpdateDarkling() then
            mDarklingAgent:MoveTo(tankSearchWaypointMirror, true, true, true)
          end
        end
        _T.gTankSpawner = _T.gDarklingAvatar:Attach(tankSpawnerType, Symbol("GAME_R1_WEAPON1"), Vector(-0.134, -0.395, 0), Rotation(0, 0, 5))
        if not IsNull(_T.gTankSpawner) then
          ObjectPortHandler(_T.gTankSpawner, "OnObjectSpawned")
        end
        while darklingCarryActionMirrorUsed == false and _T.gGenerateTanks do
          mDarklingAgent:UseContextAction(darklingCarryActionMirror, false)
          Sleep(1)
        end
        darklingCarryActionMirrorUsed = false
        if _T.gGenerateTanks then
          mDarklingAgent:SetIdleAnimation(darklingCarryIdleMirrorAnim, true)
        end
      else
        mDarklingAgent:MoveTo(tankSearchWaypoint, true, true, true)
        while not _T.gGenerateTanks do
          Sleep(0)
          if UpdateDarkling() then
            mDarklingAgent:MoveTo(tankSearchWaypoint, true, true, true)
          end
        end
        _T.gTankSpawner = _T.gDarklingAvatar:Attach(tankSpawnerType, Symbol("GAME_L1_WEAPON1"), Vector(0.134, -0.395, 0), Rotation(0, 0, -5))
        if not IsNull(_T.gTankSpawner) then
          ObjectPortHandler(_T.gTankSpawner, "OnObjectSpawned")
        end
        while darklingCarryActionUsed == false and _T.gGenerateTanks do
          mDarklingAgent:UseContextAction(darklingCarryAction, false)
          Sleep(1)
        end
        darklingCarryActionUsed = false
        if _T.gGenerateTanks then
          mDarklingAgent:SetIdleAnimation(darklingCarryIdleAnim, true)
        end
      end
      if not firstTank and 0 < player:GetHealth() then
        player:PlaySound(jackieVO, false)
      end
      Sleep(delayBeforeTankCallout)
      UpdateDarkling()
      if firstTank then
        _T.gDarklingAvatar:PlaySound(darklingTankCallout[1], false)
      else
        _T.gDarklingAvatar:PlaySound(darklingTankCallout[math.random(2, #darklingTankCallout)], false)
      end
      while true do
        timeElapsed = timeElapsed + DeltaTime()
        if 10 < timeElapsed then
          timeElapsed = 0
          if firstTank then
            PlaySound(_T.gDarklingAvatar, darklingTankCallout[1], 0, false, false)
          else
            PlaySound(_T.gDarklingAvatar, darklingTankCallout[math.random(2, #darklingTankCallout)], 0, false, false)
          end
        end
        if _T.gPlayerGrabbedTank then
          break
        elseif not _T.gGenerateTanks and not IsNull(_T.gTankSpawner) then
          gRegion:CreateEntity(tankType, _T.gTankSpawner:GetPosition(), _T.gTankSpawner:GetRotation())
          _T.gTankSpawner:Destroy()
          mDarklingAgent:PlayAnimation(darklingReturnToIdleAnim, false)
          mDarklingAgent:SetIdleAnimation(nil)
          break
        end
        Sleep(0)
        if UpdateDarkling() then
          break
        end
      end
      if not IsNull(_T.gTankSpawner) then
        _T.gTankSpawner:Destroy()
      end
      _T.gPlayerGrabbedTank = false
      tank = gRegion:FindNearest(tankType, Vector())
      if not IsNull(tank) then
        tank:ScriptRunChildScript(Symbol("DistanceCheck"), false)
      end
      if not _T.gCraneDead and _T.gGenerateTanks then
        if firstTank then
          _T.gDarklingAvatar:PlaySound(darklingSuggestTankThrow[1], false)
        else
          _T.gDarklingAvatar:PlaySound(darklingSuggestTankThrow[math.random(2, #darklingSuggestTankThrow)], false)
        end
      end
      timeElapsed = 0
      firstTank = false
      Sleep(tankSpawnDelay)
    end
    Sleep(0)
  end
  if not IsNull(_T.gTankSpawner) then
    _T.gTankSpawner:Destroy()
  end
  CleanUpTanks(0)
end
function OnObjectSpawned(entity)
  _T.gPlayerGrabbedTank = true
  local agent = _T.gDarklingAvatar:GetAgent()
  agent:PlayAnimation(darklingReturnToIdleAnim, false)
  agent:SetIdleAnimation(nil)
  CleanUpTanks(maxTanks)
end
function DistanceCheck(entity)
  local avatar = gRegion:GetPlayerAvatar()
  local playerPos = avatar:GetPosition()
  local tankPos = entity:GetPosition()
  local dist = 0
  while not IsNull(entity) and dist < maxTossDistance do
    playerPos = avatar:GetPosition()
    tankPos = entity:GetPosition()
    dist = Distance(playerPos, tankPos)
    Sleep(0)
  end
  if not IsNull(entity) then
    entity:Destroy()
  end
end
function CleanUpAllTanks()
  local tankList = gRegion:FindAll(tankType, Vector(), 0, INF)
  if not IsNull(tankList) then
    for i = 1, #tankList do
      tankList[i]:SetVisibility(false)
    end
  end
end
