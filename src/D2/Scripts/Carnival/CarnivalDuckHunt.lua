timeLimit = 30
largePrizeScore = 1000
mediumPrizeScore = 500
smallPrizeScore = 250
pointValue = 35
rotation = Rotation()
CameraOnly = false
snapTime = 1
moversRowBottom = {
  Instance()
}
moversRowMiddle = {
  Instance()
}
moversRowTop = {
  Instance()
}
jackieModifierUnequipCarnieGun = Instance()
jackieModifierEquipCarnieGun = Instance()
scoreCounter = {
  Symbol()
}
waypoint = Instance()
templateDecos = {
  Instance()
}
duckDecoration = {
  Type()
}
duckShootAvatarType = Type()
hitProxyType = Type()
hitSuccess = Resource()
hud = Resource()
jennySuccess = {
  Resource()
}
jennyAlmost = {
  Resource()
}
local SetHudVisible = function(visible)
  local movieInstance = gFlashMgr:FindMovie(hud)
  if visible then
    movieInstance:SetVariable("WeaponWheel._visible", true)
    movieInstance:Execute("SetHudAlpha", 100)
  else
    movieInstance:Execute("SetHudAlpha", 0)
    movieInstance:SetVariable("WeaponWheel._visible", false)
  end
end
local AttachDuck = function(mover, pointValueChance)
  local attachment
  if pointValueChance == 35 then
    attachment = mover:Attach(duckDecoration[1], Symbol(), Vector(), Rotation(90, 0, 0))
  elseif pointValueChance == 50 then
    attachment = mover:Attach(duckDecoration[2], Symbol(), Vector(), Rotation(-90, 0, 0))
  else
    attachment = mover:Attach(duckDecoration[3], Symbol(), Vector(), Rotation(90, 0, 0))
  end
end
local function Initialize()
  for i = 1, #moversRowBottom do
    AttachDuck(moversRowBottom[i], 35)
  end
  for i = 1, #moversRowMiddle do
    AttachDuck(moversRowMiddle[i], 50)
  end
  for i = 1, #moversRowTop do
    AttachDuck(moversRowTop[i], 100)
  end
  _T.gTotalPoints = 0
  _T.gDuckTypes = duckDecoration
  templateDecos[1]:ScriptRunChildScript(Symbol("MoveBottomRow"), false)
  templateDecos[2]:ScriptRunChildScript(Symbol("MoveMiddleRow"), false)
  templateDecos[3]:ScriptRunChildScript(Symbol("MoveTopRow"), false)
end
function MoveBottomRow(entity)
  Sleep(3)
  local delay = 30 / #moversRowBottom
  for i = 1, #moversRowBottom do
    moversRowBottom[i]:FirePort("Start")
    Sleep(delay)
  end
end
function MoveMiddleRow(entity)
  Sleep(1)
  local delay = 18 / #moversRowMiddle
  for i = 1, #moversRowMiddle do
    moversRowMiddle[i]:FirePort("Start")
    Sleep(delay)
  end
end
function MoveTopRow(entity)
  Sleep(3)
  local delay = 12 / #moversRowTop
  for i = 1, #moversRowTop do
    moversRowTop[i]:FirePort("Start")
    Sleep(delay)
  end
end
function SnapTo()
  local player = gRegion:GetPlayerAvatar()
  local startPos = player:GetPosition()
  local startRot = player:GetView()
  local wayPos = waypoint:GetPosition()
  local wayRot = waypoint:GetRotation()
  local t = 0
  while t < 1 do
    local pos = LerpVector(startPos, wayPos, t)
    local rot = LerpRotation(startRot, wayRot, t)
    if CameraOnly == false then
      player:SetPosition(pos)
    end
    player:SetView(player:GetView())
    player:SetView(rot)
    t = t + DeltaTime() / snapTime
    Sleep(0)
  end
end
function MainLoop()
  local timeElapsed = 0
  local playerAvatar = gRegion:GetPlayerAvatar()
  local player = playerAvatar:GetPlayer()
  local string1
  local keepPlaying = true
  local state
  local pos = playerAvatar:GetPosition()
  local rot = playerAvatar:GetRotation()
  local newAvatar = gRegion:CreateEntity(duckShootAvatarType, pos, rot)
  local conversation = gRegion:FindTagged(Symbol("CarnieConvo"))
  local oldAvatarWaypoint = gRegion:FindTagged(Symbol("AvatarWaypoint"))
  local endCinematic = gRegion:FindTagged(Symbol("DuckHuntEndCinematic"))
  local viewClampTrigger = gRegion:FindTagged(Symbol("DuckHuntViewClamp"))
  _T.gRotation = {}
  local targets
  local almost = false
  Sleep(0)
  player:ControlAvatar(newAvatar)
  newAvatar:ScriptInventoryControl():TransferDataFromOldInventoryController(playerAvatar:ScriptInventoryControl())
  playerAvatar:Teleport(oldAvatarWaypoint[1]:GetPosition())
  newAvatar:SetViewOffset(Rotation(), true)
  newAvatar:ScriptRunChildScript(Symbol("SnapTo"), false)
  viewClampTrigger[1]:FirePort("Execute")
  Initialize()
  while keepPlaying do
    SetHudVisible(false)
    jackieModifierEquipCarnieGun:FirePort("Activate")
    Sleep(3)
    SetHudVisible(true)
    _T.gTotalPoints = 0
    timeElapsed = 0
    newAvatar:RemoveQuestToken(Symbol("PlayAgain"))
    while timeElapsed < timeLimit do
      if timeElapsed >= timeLimit * 0.9 then
        _T.gJennyStopCallout = true
      end
      if timeElapsed >= timeLimit * 0.7 and _T.gTotalPoints >= 180 and not almost then
        _T.gJennyCalloutType = "Almost"
        almost = true
      end
      Sleep(0)
      timeElapsed = timeElapsed + DeltaTime()
    end
    for i = 1, #moversRowBottom do
      moversRowBottom[i]:FirePort("Stop")
    end
    for i = 1, #moversRowMiddle do
      moversRowMiddle[i]:FirePort("Stop")
    end
    for i = 1, #moversRowTop do
      moversRowTop[i]:FirePort("Stop")
    end
    if _T.gTotalPoints < 200 then
      gRegion:GetGameRules():RestartCheckPoint()
      return
    end
    if _T.gTotalPoints >= 1000 then
      playerAvatar:SetQuestTokenState(Symbol("DucksHighScore"), Engine.QTS_COMPLETE)
    end
    jackieModifierUnequipCarnieGun:FirePort("Activate")
    conversation[1]:FirePort("Enable")
    _T.gConversationEnabled = true
    while _T.gConversationEnabled do
      Sleep(0)
    end
    state = newAvatar:GetQuestTokenState(Symbol("PlayAgain"))
    if state == Engine.QTS_NOT_FOUND then
      keepPlaying = false
    else
      for i = 1, #moversRowBottom do
        moversRowBottom[i]:FirePort("Start")
      end
      for i = 1, #moversRowMiddle do
        moversRowMiddle[i]:FirePort("Start")
      end
      for i = 1, #moversRowTop do
        moversRowTop[i]:FirePort("Start")
      end
    end
  end
  playerAvatar:Teleport(newAvatar:GetPosition())
  player:ControlAvatar(playerAvatar)
  playerAvatar:ScriptInventoryControl():TransferDataFromOldInventoryController(newAvatar:ScriptInventoryControl())
  playerAvatar:SetViewOffset(Rotation(), true)
  newAvatar:Destroy()
  endCinematic[1]:FirePort("StartPlaying")
  while endCinematic[1]:IsPlaying() do
    Sleep(0)
  end
  for i = 1, #duckDecoration do
    targets = gRegion:FindAll(duckDecoration[i], Vector(), 0, INF)
    for k = #targets, 1, -1 do
      targets[k]:Destroy()
    end
  end
  _T.gTotalPoints = 970
  playerAvatar:ScriptRunChildScript(Symbol("UpdateScoreboard"), true)
end
function ConversationDisabled()
  _T.gConversationEnabled = false
end
local AnimateDeath = function(entity, angle)
  local y = 0
  local t = 0
  local oldbank = rotation.bank
  local newRot = Rotation()
  newRot.bank = rotation.bank
  newRot.heading = rotation.heading
  newRot.pitch = rotation.pitch
  while t < 0.25 do
    newRot.bank = Lerp(oldbank, angle, t * 4)
    entity:SetAttachLocalSpace(Vector(), newRot)
    t = t + DeltaTime()
    Sleep(0)
  end
end
function FancyRotate(entity)
  local rotationCurrent = entity:GetRotation()
  local rotationTarget = _T.gRotation[entity:GetFullName()]
  local rotationInterval
  local timeElapsed = 0
  local newRotation = rotationCurrent
  if rotationCurrent ~= -1 * rotationTarget then
    while timeElapsed < 0.25 do
      timeElapsed = timeElapsed + DeltaTime()
      newRotation.bank = newRotation.bank + 5
      entity:SetRotation(newRotation)
      Sleep(0)
    end
    newRotation.bank = -1 * rotationTarget
    entity:SetRotation(newRotation)
  end
end
function UpdateScoreboard(entity)
  local scoreString = tostring(_T.gTotalPoints)
  local wheel
  for i = string.len(scoreString), 1, -1 do
    wheel = gRegion:FindTagged(scoreCounter[i + 4 - string.len(scoreString)])
    _T.gRotation[wheel[1]:GetFullName()] = tonumber(string.sub(scoreString, i, i)) * 36
    wheel[1]:ScriptRunChildScript(Symbol("FancyRotate"), false)
    Sleep(0.1)
  end
end
function OnDamaged(entity)
  local parent, duckType, newEntity
  entity:Attach(hitProxyType, Symbol(), Vector(0, 0.2, 0), Rotation())
  _T.gTotalPoints = _T.gTotalPoints + pointValue
  parent = entity:GetAttachParent()
  parent:ScriptRunChildScript(Symbol("UpdateScoreboard"), false)
  entity:PlaySound(hitSuccess, false)
  _T.gCurrentTargetSuccess = _T.gCurrentTargetSuccess + 1
  if _T.gJennyCalloutType ~= "Almost" and _T.gCurrentTargetSuccess >= 3 then
    _T.gJennyCalloutType = "Success"
    _T.gCurrentTargetSuccess = 0
  end
  if pointValue == 35 then
    duckType = _T.gDuckTypes[1]
    AnimateDeath(entity, -90)
  elseif pointValue == 50 then
    duckType = _T.gDuckTypes[2]
    AnimateDeath(entity, 90)
  else
    duckType = _T.gDuckTypes[3]
    AnimateDeath(entity, -90)
  end
  Sleep(10)
  newEntity = parent:Attach(duckType, Symbol(), Vector(0, -0.3, 0), rotation)
  newEntity:SetAttachLocalSpace(Vector(), rotation)
  entity:Destroy()
end
function JennyGameCallouts(agent)
  local jenny = agent
  local successIndex = math.random(1, #jennySuccess)
  local almostIndex = math.random(1, #jennyAlmost)
  _T.gJennyCalloutType = ""
  _T.gCurrentTargetSuccess = 0
  while true do
    if not _T.gJennyStopCallout then
      if _T.gJennyCalloutType == "Success" then
        if successIndex > #jennyAlmost then
          successIndex = 1
        end
        jenny:PlaySpeech(jennySuccess[successIndex], true)
        successIndex = successIndex + 1
        Sleep(5)
        if _T.gJennyCalloutType ~= "Almost" then
          _T.gJennyCalloutType = ""
        end
      elseif _T.gJennyCalloutType == "Almost" then
        if almostIndex > #jennyAlmost then
          almostIndex = 1
        end
        jenny:PlaySpeech(jennyAlmost[almostIndex], true)
        almostIndex = almostIndex + 1
        Sleep(2)
        _T.gJennyCalloutType = ""
      end
    end
    if IsNull(jenny) then
      return
    end
    Sleep(0)
  end
end
