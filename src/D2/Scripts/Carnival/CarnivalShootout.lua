timeLimit = 60
largePrizeScore = 1000
pointValue = 10
timeTargetVisible = 3
timeTargetIntervalMin = 2
timeTargetIntervalMax = 4
simultaneousTargets = {
  1,
  2,
  3
}
roundChange = {
  20,
  40,
  60
}
achievementEventTag = Symbol("CARNIVAL_HIGH_SCORE")
CameraOnly = false
snapTime = 1
waypoint = Instance()
movers = {
  Instance()
}
unequipModifier = Instance()
equipModifier = Instance()
props = {
  Instance()
}
scoreCounter = {
  Symbol()
}
decorationType = Type()
lastChanceAvatarType = Type()
jennyAvatarType = Type()
hitSuccess = Resource()
hud = Resource()
jennySuccess = {
  Resource()
}
jennyFailure = {
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
    movieInstance:SetVariable("WeaponWheel._visible", false)
    movieInstance:Execute("SetHudAlpha", 0)
  end
end
local Initialize = function()
  local attachments
  _T.gTargetStatus = {}
  _T.gTotalPoints = 0
  if IsNull(_T.gPropStatus) then
    _T.gPropStatus = {}
  end
  for i = 1, #movers do
    _T.gTargetStatus[movers[i]:GetFullName()] = "Hidden"
    ObjectPortHandler(movers[i], "OnDone")
    attachments = movers[i]:GetAllAttachments(decorationType)
    attachments[2]:FirePort("Hide")
    attachments[3]:FirePort("Hide")
  end
  for i = 1, #props do
    if _T.gPropStatus[props[i]:GetFullName()] == "Damaged" then
      props[i]:FirePort("Start")
    end
    _T.gPropStatus[props[i]:GetFullName()] = "Undamaged"
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
  local timeSinceLastTarget = 0
  local timeUntilNextTarget
  local playerAvatar = gRegion:GetPlayerAvatar()
  local player = playerAvatar:GetPlayer()
  local targetMover, goodGuyChance, attachments
  local round = 1
  local pos = playerAvatar:GetPosition()
  local rot = playerAvatar:GetRotation()
  local newAvatar
  local oldAvatarWaypoint = gRegion:FindTagged(Symbol("AvatarWaypoint"))
  local conversation = gRegion:FindTagged(Symbol("CarnieConvo2"))
  local initialConvo = gRegion:FindTagged(Symbol("Game2InitialConvo"))
  local viewClampTrigger = gRegion:FindTagged(Symbol("Game2ViewClamp"))
  local keepPlaying = true
  local state
  local showFriendly = false
  local smallTargetShown = false
  local targetsShown = 0
  local targetIndex = 0
  local almost = false
  _T.gRotation = {}
  Sleep(0)
  if IsNull(_T.gPlayerAvatar) then
    newAvatar = gRegion:CreateEntity(lastChanceAvatarType, pos, rot)
    _T.gPlayerAvatar = playerAvatar
    player:ControlAvatar(newAvatar)
    newAvatar:ScriptInventoryControl():TransferDataFromOldInventoryController(playerAvatar:ScriptInventoryControl())
    playerAvatar:Teleport(oldAvatarWaypoint[1]:GetPosition())
    newAvatar:SetViewOffset(Rotation(), true)
    initialConvo[1]:FirePort("Enable")
  else
    newAvatar = playerAvatar
  end
  newAvatar:ScriptRunChildScript(Symbol("SnapTo"), false)
  viewClampTrigger[1]:FirePort("Execute")
  Initialize()
  _T.gTotalPoints = 0
  _T.gJennyStopCallout = false
  _T.gCurrentTargetSuccess = 0
  _T.gCurrentTargetTotal = 0
  _T.gCurrentHidden = 0
  timeUntilNextTarget = math.random(timeTargetIntervalMin, timeTargetIntervalMax)
  SetHudVisible(false)
  equipModifier:FirePort("Activate")
  Sleep(3)
  SetHudVisible(true)
  while timeElapsed < timeLimit do
    Sleep(0)
    timeElapsed = timeElapsed + DeltaTime()
    timeSinceLastTarget = timeSinceLastTarget + DeltaTime()
    if 1 < round and timeElapsed > roundChange[round - 1] then
      round = round + 1
    end
    if timeElapsed >= timeLimit * 0.9 then
      _T.gJennyStopCallout = true
    end
    if timeElapsed >= timeLimit * 0.7 and _T.gTotalPoints >= largePrizeScore * 0.9 and not almost then
      _T.gJennyCalloutType = "Almost"
      almost = true
    end
    if timeUntilNextTarget <= timeSinceLastTarget and round <= #simultaneousTargets then
      timeSinceLastTarget = 0
      timeUntilNextTarget = math.random(timeTargetIntervalMin, timeTargetIntervalMax)
      goodGuyChance = math.random(1, 100)
      if goodGuyChance < 50 then
        showFriendly = true
      end
      targetMover = nil
      _T.gCurrentHidden = 0
      _T.gCurrentTargetTotal = 0
      _T.gCurrentTargetSuccess = 0
      if 1 < simultaneousTargets[round] then
        for i = 1, simultaneousTargets[round] do
          while IsNull(targetMover) or _T.gTargetStatus[targetMover:GetFullName()] ~= "Hidden" do
            if not smallTargetShown then
              targetIndex = math.random(1, 4)
            else
              targetIndex = math.random(1, #movers)
            end
            targetMover = movers[targetIndex]
            Sleep(0)
          end
          if targetIndex <= 4 then
            smallTargetShown = true
          end
          attachments = targetMover:GetAllAttachments(decorationType)
          if showFriendly then
            attachments[2]:FirePort("Show")
            showFriendly = false
          else
            attachments[3]:FirePort("Show")
            _T.gCurrentTargetTotal = _T.gCurrentTargetTotal + 1
          end
          targetMover:ScriptRunChildScript(Symbol("MoveTarget"), false)
        end
        smallTargetShown = false
      else
        if targetsShown < 3 then
          targetMover = movers[math.random(5, 8)]
          attachments = targetMover:GetAllAttachments(decorationType)
          if targetsShown == 2 then
            attachments[2]:FirePort("Show")
          else
            attachments[3]:FirePort("Show")
            _T.gCurrentTargetTotal = _T.gCurrentTargetTotal + 1
          end
        else
          targetMover = movers[math.random(1, 4)]
          attachments = targetMover:GetAllAttachments(decorationType)
          attachments[3]:FirePort("Show")
          round = round + 1
        end
        targetMover:ScriptRunChildScript(Symbol("MoveTarget"), false)
        targetsShown = targetsShown + 1
      end
    end
  end
  unequipModifier:FirePort("Activate")
  if _T.gTotalPoints >= largePrizeScore then
    _T.gPlayerAvatar:Teleport(newAvatar:GetPosition())
    player:ControlAvatar(_T.gPlayerAvatar)
    _T.gPlayerAvatar:CameraControl():ForcePostProcessSync()
    playerAvatar:ScriptInventoryControl():TransferDataFromOldInventoryController(newAvatar:ScriptInventoryControl())
    _T.gPlayerAvatar:SetViewOffset(Rotation(), true)
    newAvatar:Destroy()
    state = newAvatar:GetQuestTokenState(Symbol("LargePrize"))
    if state == Engine.QTS_NOT_FOUND then
      _T.gPlayerAvatar:SetQuestTokenState(Symbol("LargePrize"), Engine.QTS_COMPLETE)
      state = _T.gPlayerAvatar:GetQuestTokenState(Symbol("LargePrize"))
    end
    if _T.gTotalPoints >= 1000 then
      local duckState = _T.gPlayerAvatar:GetQuestTokenState(Symbol("DucksHighScore"))
      if duckState == Engine.QTS_COMPLETE then
        local humans = gRegion:GetHumanPlayers()
        for i = 1, #humans do
          gChallengeMgr:NotifyTag(humans[i], achievementEventTag)
        end
      end
    end
    Sleep(0)
  end
  timeSinceLastTarget = 0
  timeElapsed = 0
  round = 1
end
function SetScoreAfterCin()
  local scoreString = "1125"
  local wheel
  for i = string.len(scoreString), 1, -1 do
    wheel = gRegion:FindTagged(scoreCounter[i + 4 - string.len(scoreString)])
    _T.gRotation[wheel[1]:GetFullName()] = tonumber(string.sub(scoreString, i, i)) * 36
    wheel[1]:ScriptRunChildScript(Symbol("FancyRotate"), false)
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
function MoveTarget(entity)
  entity:FirePort("Start")
  _T.gTargetStatus[entity:GetFullName()] = "Showing"
  Sleep(timeTargetVisible)
  if _T.gTargetStatus[entity:GetFullName()] == "Visible" then
    _T.gTargetStatus[entity:GetFullName()] = "Hiding"
    entity:FirePort("Reverse")
  end
end
function TargetDamaged(entity)
  local mover, scoreString, wheel, length
  if IsNull(_T.gTotalPoints) then
    return
  end
  mover = entity:GetAttachParent()
  if pointValue > 0 then
    _T.gCurrentTargetSuccess = _T.gCurrentTargetSuccess + 1
  else
    _T.gCurrentTargetSuccess = _T.gCurrentTargetSuccess - 1
  end
  if _T.gTargetStatus[mover:GetFullName()] ~= "Hidden" and _T.gTargetStatus[mover:GetFullName()] ~= "Damaged" then
    if _T.gTargetStatus[mover:GetFullName()] ~= "Hiding" then
      mover:FirePort("Reverse")
    end
    _T.gTargetStatus[mover:GetFullName()] = "Damaged"
    _T.gTotalPoints = _T.gTotalPoints + pointValue
    if _T.gTotalPoints < 0 then
      _T.gTotalPoints = 0
    end
    scoreString = tostring(_T.gTotalPoints)
    length = string.len(scoreString)
    if length < 4 then
      for i = 1, 4 - length do
        scoreString = "0" .. scoreString
      end
    end
    for i = string.len(scoreString), 1, -1 do
      wheel = gRegion:FindTagged(scoreCounter[i + 4 - string.len(scoreString)])
      _T.gRotation[wheel[1]:GetFullName()] = tonumber(string.sub(scoreString, i, i)) * 36
      wheel[1]:ScriptRunChildScript(Symbol("FancyRotate"), false)
      Sleep(0.1)
    end
    entity:PlaySound(hitSuccess, false)
  end
end
function PropDamaged(entity)
  local mover = entity:GetAttachParent()
  local scoreString, wheel
  if IsNull(_T.gTotalPoints) then
    return
  end
  if _T.gPropStatus[mover:GetFullName()] == "Undamaged" then
    _T.gTotalPoints = _T.gTotalPoints + pointValue
    entity:PlaySound(hitSuccess, false)
    scoreString = tostring(_T.gTotalPoints)
    for i = string.len(scoreString), 1, -1 do
      wheel = gRegion:FindTagged(scoreCounter[i + 4 - string.len(scoreString)])
      _T.gRotation[wheel[1]:GetFullName()] = tonumber(string.sub(scoreString, i, i)) * 36
      wheel[1]:ScriptRunChildScript(Symbol("FancyRotate"), false)
      Sleep(0.1)
    end
    mover:FirePort("Start")
    _T.gPropStatus[mover:GetFullName()] = "Damaged"
  end
end
function OnDone(entity)
  local attachments = entity:GetAllAttachments(decorationType)
  if _T.gTargetStatus[entity:GetFullName()] == "Showing" then
    _T.gTargetStatus[entity:GetFullName()] = "Visible"
  elseif _T.gTargetStatus[entity:GetFullName()] == "Hiding" then
    _T.gTargetStatus[entity:GetFullName()] = "Hidden"
    Sleep(1)
    attachments[2]:FirePort("Hide")
    attachments[3]:FirePort("Hide")
    _T.gCurrentHidden = _T.gCurrentHidden + 1
  elseif _T.gTargetStatus[entity:GetFullName()] == "Damaged" then
    _T.gTargetStatus[entity:GetFullName()] = "Hidden"
    Sleep(1)
    attachments[2]:FirePort("Hide")
    attachments[3]:FirePort("Hide")
    _T.gCurrentHidden = _T.gCurrentHidden + 1
  end
  if _T.gCurrentHidden == _T.gCurrentTargetTotal and _T.gJennyCalloutType ~= "Almost" then
    if 1 <= _T.gCurrentTargetSuccess then
      _T.gJennyCalloutType = "Success"
    elseif _T.gCurrentTargetTotal > 0 then
      _T.gJennyCalloutType = "Failure"
    end
  end
end
function JennyGameCallouts(agent)
  local jenny = agent
  local successIndex = math.random(1, #jennySuccess)
  local failIndex = math.random(1, #jennyFailure)
  local almostIndex = math.random(1, #jennyAlmost)
  _T.gJennyCalloutType = ""
  while true do
    if not _T.gJennyStopCallout then
      if _T.gJennyCalloutType == "Success" then
        if successIndex > #jennyAlmost then
          successIndex = 1
        end
        jenny:PlaySpeech(jennySuccess[successIndex], true)
        successIndex = successIndex + 1
        Sleep(2)
        if _T.gJennyCalloutType ~= "Almost" then
          _T.gJennyCalloutType = ""
        end
      elseif _T.gJennyCalloutType == "Failure" then
        if failIndex > #jennyFailure then
          failIndex = 1
        end
        jenny:PlaySpeech(jennyFailure[failIndex], true)
        failIndex = failIndex + 1
        Sleep(2)
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
