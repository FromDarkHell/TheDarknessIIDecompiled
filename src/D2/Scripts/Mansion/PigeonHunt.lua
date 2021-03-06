targets = {
  Instance()
}
triggers = {
  Instance()
}
pigeonType = Type()
targetAnimTakeOff = Resource()
targetAnimFly = Resource()
startGameWaypoint = Instance()
pigeonKillEffect = Type()
pigeonIdleAnims = {
  Resource()
}
hitProxyType = Type()
hitProxies = {
  Instance()
}
equipWeaponModifier = Instance()
unequipWeaponModifier = Instance()
pigeonFlyTriggers = {
  Instance()
}
gameStartFaceWaypoint = Instance()
gameEndFaceWaypoint = Instance()
greatScoreDialogs = {
  Resource()
}
decentScoreDialogs = {
  Resource()
}
terribleScoreDialogs = {
  Resource()
}
dolfoAvatarType = Type()
terraceZoneAttribs = Instance()
npcTypes = {
  Type()
}
hideWaypoints = {
  Instance()
}
pigeonHitProxyType = Type()
doorMovers = {
  Instance()
}
hudSwf = WeakResource()
timeLimit = 120
hudSwf = WeakResource()
pigeonSuccessToken = Symbol("PigeonSlayer")
bottleSuccessToken = Symbol("HangoverCure")
dolfoImpressAchievementToken = Symbol("DOLFO_IMPRESSED")
local pigeonCount = 0
local hidden = false
local positions = {}
local avatars = {}
local routes = {}
local HubReticle = function(reticleShow)
  local movieInstance
  while IsNull(movieInstance) do
    Sleep(0)
    movieInstance = gFlashMgr:FindMovie(hudSwf)
  end
  movieInstance:Execute("ReticuleHubShow", reticleShow)
end
local function ToggleHideNPCFromTerrace()
  local avatar, agent, zone
  local terraceZone = terraceZoneAttribs:GetZone():GetFullName()
  local iLimit
  if hidden then
    iLimit = #avatars
  else
    iLimit = #npcTypes
  end
  for i = 1, iLimit do
    if not hidden then
      avatar = gRegion:FindNearest(npcTypes[i], Vector(), INF)
      if not IsNull(avatar) then
        agent = avatar:GetAgent()
        zone = avatar:GetZone():GetFullName()
        if zone == terraceZone then
          table.insert(positions, avatar:GetPosition())
          table.insert(avatars, avatar)
          if not IsNull(agent:GetPatrolRoute()) then
            table.insert(routes, agent:GetPatrolRoute())
          else
            table.insert(routes, "None")
          end
          avatar:Teleport(hideWaypoints[i]:GetPosition())
          agent:SetPatrolRoute(nil)
        end
      end
    else
      avatars[i]:Teleport(positions[i])
      avatars[i]:GetAgent():ReturnToAiControl()
      avatars[i]:GetAgent():StopScriptedMode()
      if routes[i] ~= "None" then
        avatars[i]:GetAgent():SetPatrolRoute(routes[i])
      end
    end
  end
  hidden = not hidden
end
function PigeonTakeoff()
  for i = 1, #targets do
    targets[i]:ScriptRunChildScript(Symbol("PigeonPlayAnims"), false)
    Sleep(0.2)
  end
end
function ProfileSaved()
  print("Saving your profile..")
end
function PigeonPlayAnims(entity)
  local pigeon
  local elapsedTime = 0
  entity:FirePort("Start")
  pigeon = entity:GetAttachment(pigeonType)
  if not IsNull(pigeon) then
    pigeon:Attach(pigeonHitProxyType, Symbol(), Vector(), Rotation())
  end
  if not IsNull(pigeon) then
    pigeon:PlayAnimation(targetAnimTakeOff, true)
  end
  if not IsNull(pigeon) then
    pigeon:LoopAnimation(targetAnimFly)
  end
  Sleep(5)
  if not IsNull(pigeon) then
    while elapsedTime < 2 and not IsNull(pigeon) do
      pigeon:SetDissolve(Lerp(0, 1, elapsedTime))
      elapsedTime = elapsedTime + DeltaTime()
      Sleep(0)
    end
  end
  if not IsNull(pigeon) then
    pigeon:Destroy()
  end
end
local SetTargets = function(targets)
  local pigeon
  for i = 1, #targets do
    targets[i]:FirePort("Beginning")
    pigeon = targets[i]:Attach(pigeonType, Symbol())
    pigeon:LoopAnimation(pigeonIdleAnims[math.random(1, #pigeonIdleAnims)])
  end
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
function StoreHitProxyPositionRotation()
  if IsNull(_T.gHitProxiesPos) then
    _T.gHitProxiesPos = {}
  end
  if IsNull(_T.gHitProxiesRot) then
    _T.gHitProxiesRot = {}
  end
  for i = 1, #hitProxies do
    table.insert(_T.gHitProxiesPos, hitProxies[i]:GetPosition())
    table.insert(_T.gHitProxiesRot, hitProxies[i]:GetRotation())
  end
end
function PigeonHunt()
  local timeElapsed = 0
  local playerAvatar = gRegion:GetPlayerAvatar()
  local pigeons
  local temp = pigeonFlyTriggers
  local movieInstance, totalPigeons
  local avatar = gRegion:FindNearest(dolfoAvatarType, Vector(), INF)
  local agent = avatar:GetAgent()
  local playerPosition, randomBark
  Fade(0, 1, 1)
  for i = 1, #doorMovers do
    doorMovers[i]:FirePort("Start")
  end
  ToggleHideNPCFromTerrace()
  if IsNull(_T.gHitProxies) then
    _T.gHitProxies = hitProxies
  end
  for i = 1, #_T.gHitProxies do
    if IsNull(_T.gHitProxies[i]) then
      _T.gHitProxies[i] = gRegion:CreateEntity(hitProxyType, _T.gHitProxiesPos[i], _T.gHitProxiesRot[i])
    end
  end
  while not IsNull(gRegion:FindNearest(pigeonType, Vector(), INF)) do
    Sleep(0)
  end
  SetTargets(targets)
  equipWeaponModifier:FirePort("Activate")
  playerPosition = playerAvatar:GetPosition()
  playerAvatar:Teleport(startGameWaypoint:GetPosition())
  playerAvatar:FaceTo(gameStartFaceWaypoint:GetPosition())
  Sleep(0.5)
  for i = 1, #triggers do
    triggers[i]:FirePort("Enable")
  end
  Fade(1, 0, 1)
  movieInstance = gFlashMgr:FindMovie(hudSwf)
  GlobalPortHandler(pigeonType, "OnDamaged")
  GlobalPortHandler(hitProxyType, "OnDamaged")
  pigeons = gRegion:FindAll(pigeonType, Vector(), 0, INF)
  _T.gPigeonsMissed = #pigeons
  totalPigeons = #pigeons
  if not IsNull(movieInstance) then
    movieInstance:Execute("MiniGameSetVisible", "1")
    movieInstance:Execute("MiniGameSetTime", "00.00")
    movieInstance:Execute("MiniGameSetBestScore", _T.gBestScore)
    movieInstance:Execute("MiniGameSetScore", "0," .. totalPigeons)
  end
  while not IsNull(pigeons) do
    Sleep(0)
    timeElapsed = timeElapsed + DeltaTime()
    movieInstance:Execute("MiniGameSetTime", tostring(timeLimit - timeElapsed))
    movieInstance:Execute("MiniGameSetScore", tostring(pigeonCount) .. "," .. totalPigeons)
    pigeons = gRegion:FindAll(pigeonType, Vector(), 0, INF)
    if timeElapsed > timeLimit then
      for i = 1, #pigeons do
        pigeons[i]:Destroy()
      end
      pigeons = nil
    end
  end
  if IsNull(_T.gBestScore) or pigeonCount >= _T.gBestScore then
    _T.gBestScore = pigeonCount
  end
  timeElapsed = 0
  unequipWeaponModifier:FirePort("Activate")
  Fade(0, 1, 1)
  for i = 1, #pigeonFlyTriggers do
    pigeonFlyTriggers[i]:FirePort("Disable")
  end
  for i = 1, #doorMovers do
    doorMovers[i]:FirePort("Start")
  end
  playerAvatar:Teleport(playerPosition)
  playerAvatar:FaceTo(gameEndFaceWaypoint:GetPosition())
  ToggleHideNPCFromTerrace()
  movieInstance:Execute("MiniGameSetBestScore", _T.gBestScore)
  Fade(1, 0, 1)
  local avatar = gRegion:FindNearest(dolfoAvatarType, Vector(), INF)
  print("You finished the pigeon hunt game! Good for you!")
  if 20 <= pigeonCount then
    print("You impressed Dolfo! YAAAAAAAAAAAAAAAY")
    randomBark = RandomInt(1, #greatScoreDialogs)
    avatar:PlaySpeech(greatScoreDialogs[randomBark], true)
    local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    local d2profileData = playerProfile:GetGameSpecificData()
    d2profileData:SetCompletedPigeonGame(true)
    Engine.GetPlayerProfileMgr():ScriptSaveProfile(0, "ProfileSaved")
    if d2profileData:HasCompletedBottleGame() then
      print("Unlocking the dolfo impressed achievement, because you learned to be better bro!")
      gChallengeMgr:NotifyTag(playerAvatar:GetPlayer(), dolfoImpressAchievementToken)
    else
      print("You haven't impressed dolfo in the bottle game yet")
    end
  elseif 15 < pigeonCount then
    print("You just need to be better bro!" .. pigeonCount .. " pigeons killed")
    randomBark = RandomInt(1, #decentScoreDialogs)
    avatar:PlaySpeech(decentScoreDialogs[randomBark], true)
  else
    print("Being better won't help you" .. pigeonCount .. " pigeons killed")
    randomBark = RandomInt(1, #terribleScoreDialogs)
    avatar:PlaySpeech(terribleScoreDialogs[randomBark], true)
  end
  Sleep(2)
  agent:StopScriptedMode()
  movieInstance:Execute("MiniGameSetVisible", "0")
end
function OnDamaged(entity)
  local pos, rot
  if entity:IsA(pigeonType) then
    pos = entity:GetPosition()
    rot = entity:GetRotation()
    gRegion:CreateEntity(pigeonKillEffect, pos, rot)
    pigeonCount = pigeonCount + 1
    _T.gPigeonsMissed = _T.gPigeonsMissed - 1
  else
    for i = 1, #_T.gHitProxies do
      if _T.gHitProxies[i] == entity then
        pigeonFlyTriggers[i]:FirePort("Execute")
        break
      end
    end
  end
end
function RemoveMiniGameQuestToken()
  local player = gRegion:GetPlayerAvatar()
  player:RemoveQuestToken(Symbol("MiniGameStarted"))
end
