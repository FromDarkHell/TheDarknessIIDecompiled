targets = {
  Instance()
}
dolfoAvatarType = Type()
shootDelay = 5
shootDuration = 3
targetAnimTakeOff = Resource()
targetAnimFly = Resource()
takeOffDelay = 5
targetAnimIdle = Resource()
barks = {
  Resource()
}
barksRadius = 10
barksMaxRadius = 20
gameDuration = 30
greatScoreDialog = Resource()
decentScoreDialog = Resource()
terribleScoreDialog = Resource()
greatScoreDialogs = {
  Resource()
}
decentScoreDialogs = {
  Resource()
}
terribleScoreDialogs = {
  Resource()
}
targetTypes = {
  Type()
}
dolfoShootAtPigeons = false
gameStartWaypoint = Instance()
gameEndFaceWaypoint = Instance()
equipModifier = Instance()
unequipModifier = Instance()
stonedScript = Instance()
stopStonedScript = Instance()
minview = Rotation()
maxview = Rotation()
hudSwf = WeakResource()
dolfoConvo = Instance()
timeLimit = 45
hudSwf = WeakResource()
pigeonSuccessToken = Symbol("PigeonSlayer")
bottleSuccessToken = Symbol("HangoverCure")
dolfoImpressAchievementToken = Symbol("DOLFO_IMPRESSED")
local HubReticle = function(reticleShow)
  local movieInstance
  while IsNull(movieInstance) do
    Sleep(0)
    movieInstance = gFlashMgr:FindMovie(hudSwf)
  end
  movieInstance:Execute("ReticuleHubShow", reticleShow)
end
local ClampCamera = function()
  local player = gRegion:GetPlayerAvatar()
  local camCtrl = player:CameraControl()
  local curView = player:GetView()
  local curViewConst = Rotation()
  curViewConst.heading = curView.heading
  curViewConst.pitch = curView.pitch
  curViewConst.bank = curView.bank
  player:SetView(curView)
  camCtrl:SetViewClamp(minview, maxview)
  player:SetView(curViewConst)
end
local Fade = function(start, stop, duration)
  local timeElapsed = 0
  local playerAvatar = gRegion:GetPlayerAvatar()
  local postProcess = gRegion:GetLevelInfo().postProcess
  while duration > timeElapsed do
    postProcess.fade = Lerp(start, stop, timeElapsed / duration)
    Sleep(0)
    timeElapsed = timeElapsed + DeltaTime()
  end
  postProcess.fade = stop
end
local ResetTargets = function(applyPortHandler)
  local target
  for i = 1, #_T.gTargetPositions do
    if IsNull(_T.gTargets[i]) then
      target = gRegion:CreateEntity(targetTypes[math.random(1, #targetTypes)], _T.gTargetPositions[i], Rotation(math.random(1, 359), 0, 0))
      _T.gTargets[i] = target
    end
    if applyPortHandler then
      ObjectPortHandler(_T.gTargets[i], "OnDestroyed")
    end
  end
end
local ResetView = function()
  local player = gRegion:GetPlayerAvatar()
  local camCtrl = player:CameraControl()
  camCtrl:ResetViewClamp()
end
function PigeonTakeoff()
  local avatar = gRegion:FindNearest(dolfoAvatarType, Vector(), INF)
  local agent = avatar:GetAgent()
  if dolfoShootAtPigeons then
    agent:ShootTarget(targets[1], shootDuration, true, false)
    Sleep(shootDelay)
    avatar:PlaySpeech(barks[1], false)
  end
  for i = 1, #targets do
    targets[i]:ScriptRunChildScript(Symbol("PigeonPlayAnims"), false)
    Sleep(0.2)
  end
  Sleep(shootDuration)
end
function PigeonPlayAnims(entity)
  entity:PlayAnimation(targetAnimTakeOff, false)
  Sleep(0.5)
  entity:FirePort("Start")
  Sleep(1)
  entity:LoopAnimation(targetAnimFly)
end
local MovePlayerToPosition = function()
  local player = gRegion:GetPlayerAvatar()
  local startPos = player:GetPosition()
  local startRot = player:GetView()
  local wayPos = gameStartWaypoint:GetPosition()
  local wayRot = gameStartWaypoint:GetRotation()
  local t = 0
  while t < 1 do
    local pos = LerpVector(startPos, wayPos, t)
    local rot = LerpRotation(startRot, wayRot, t)
    player:SetPosition(pos)
    player:SetView(player:GetView())
    player:SetView(rot)
    t = t + DeltaTime() / 1
    Sleep(0)
  end
end
function ProfileSaved()
  print("Saving your profile..")
end
function DolfoMiniGame()
  local avatar = gRegion:FindNearest(dolfoAvatarType, Vector(), INF)
  _T.gObjectsDestoyed = 0
  local timeElapsed = 0
  local prevObjectsDestroyed = 0
  local lastBarkTime = -5
  local barksCntr = 1
  local movieInstance
  local playerAvatar = gRegion:GetPlayerAvatar()
  local agent = avatar:GetAgent()
  local playerPosition, randomBark, soundInstance
  Fade(0, 1, 1)
  ResetTargets(true)
  playerAvatar:SetSpeedMultiplier(0)
  playerPosition = playerAvatar:GetPosition()
  avatar:SetHidden(true)
  MovePlayerToPosition()
  ClampCamera()
  if not IsNull(stonedScript) then
    stonedScript:FirePort("Execute")
  end
  avatar:SetHidden(false)
  Fade(1, 0, 1)
  movieInstance = gFlashMgr:FindMovie(hudSwf)
  if not IsNull(movieInstance) then
    movieInstance:Execute("MiniGameSetVisible", "1")
    movieInstance:Execute("MiniGameSetTime", 0)
    movieInstance:Execute("MiniGameSetBestTime", _T.gBestTime)
    movieInstance:Execute("MiniGameSetScore", "0," .. #_T.gTargets)
  end
  equipModifier:FirePort("Activate")
  local temp = #_T.gTargets
  while _T.gObjectsDestoyed < #_T.gTargets do
    Sleep(0)
    timeElapsed = timeElapsed + DeltaTime()
    movieInstance:Execute("MiniGameSetTime", tostring(timeElapsed))
    if prevObjectsDestroyed ~= _T.gObjectsDestoyed then
      prevObjectsDestroyed = _T.gObjectsDestoyed
      movieInstance:Execute("MiniGameSetScore", tostring(_T.gObjectsDestoyed) .. "," .. #_T.gTargets)
      if 8 < timeElapsed - lastBarkTime then
        Sleep(0.5)
        soundInstance = agent:PlaySpeech(barks[barksCntr], false)
        barksCntr = barksCntr + 1
        lastBarkTime = timeElapsed
      end
    end
    if timeElapsed > timeLimit then
      break
    end
  end
  Sleep(1)
  if IsNull(_T.gBestTime) or timeElapsed < _T.gBestTime then
    _T.gBestTime = timeElapsed
  end
  Fade(0, 1, 1)
  unequipModifier:FirePort("Activate")
  agent:InterruptSpeech()
  playerAvatar:Teleport(playerPosition)
  ResetView()
  playerAvatar:FaceTo(gameEndFaceWaypoint:GetPosition())
  ResetTargets(false)
  if not IsNull(stopStonedScript) then
    stopStonedScript:FirePort("Execute")
  end
  movieInstance:Execute("MiniGameSetBestTime", _T.gBestTime)
  Fade(1, 0, 1)
  print("You finished the bottle game! Good for you!")
  if timeElapsed <= 11 then
    print("You impressed Dolfo! YAAAAAAAAAAAAAAAY")
    randomBark = RandomInt(1, #greatScoreDialogs)
    avatar:PlaySpeech(greatScoreDialogs[randomBark], true)
    local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    local d2profileData = playerProfile:GetGameSpecificData()
    d2profileData:SetCompletedBottleGame(true)
    Engine.GetPlayerProfileMgr():ScriptSaveProfile(0, "ProfileSaved")
    if d2profileData:HasCompletedPigeonGame() then
      print("Unlocking the dolfo impressed achievement, because you learned to be better bro!")
      gChallengeMgr:NotifyTag(playerAvatar:GetPlayer(), dolfoImpressAchievementToken)
    else
      print("You haven't impressed dolfo in the pigeon game yet")
    end
  elseif timeElapsed < 30 then
    print("You just need to be better bro! time elapsed = " .. timeElapsed)
    randomBark = RandomInt(1, #decentScoreDialogs)
    avatar:PlaySpeech(decentScoreDialogs[randomBark], true)
  else
    print("Being better won't help you.. time elapsed = " .. timeElapsed)
    randomBark = RandomInt(1, #terribleScoreDialogs)
    avatar:PlaySpeech(terribleScoreDialogs[randomBark], true)
  end
  movieInstance:Execute("MiniGameSetVisible", "0")
  Sleep(2)
end
function OnDestroyed(entity)
  local avatar = gRegion:FindNearest(dolfoAvatarType, Vector(), INF)
  _T.gObjectsDestoyed = _T.gObjectsDestoyed + 1
end
function StoreTargetPositions()
  _T.gTargetPositions = {}
  _T.gTargets = {}
  for i = 1, #targets do
    table.insert(_T.gTargetPositions, targets[i]:GetPosition())
    table.insert(_T.gTargets, targets[i])
  end
end
function DolfoShootAtBottles()
  local avatar = gRegion:FindNearest(dolfoAvatarType, Vector(), INF)
  local agent = avatar:GetAgent()
  local player = gRegion:GetPlayerAvatar()
  local target
  local tgtCntr = 1
  _T.gShootBottles = true
  target = _T.gTargets[math.random(1, #_T.gTargets)]
  while _T.gShootBottles do
    while Distance(player:GetPosition(), avatar:GetPosition()) < barksRadius do
      Sleep(0)
    end
    while Distance(player:GetPosition(), avatar:GetPosition()) > barksMaxRadius do
      Sleep(0)
    end
    if tgtCntr <= #targets then
      target = _T.gTargets[tgtCntr]
      tgtCntr = tgtCntr + 1
    else
      _T.gShootBottles = false
    end
    if not IsNull(target) then
      agent:ShootTarget(target, shootDuration, true, false)
    end
    dolfoConvo:FirePort("Disable")
    if Distance(player:GetPosition(), avatar:GetPosition()) > barksRadius then
      avatar:PlaySound(barks[math.random(1, #barks)], true)
      dolfoConvo:FirePort("Enable")
      Sleep(5)
    end
    Sleep(0)
  end
end
function DolfoStopShoot()
  _T.gShootBottles = false
end
