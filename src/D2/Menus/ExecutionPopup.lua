movieHUD = WeakResource()
local mButtonStates = {}
local mTimer = 0
local mHasHealthTalent = 0
function UpdateTimer(movie, timeLeft)
  timeLeft = tonumber(timeLeft)
  if timeLeft ~= mTimer then
    FlashMethod(movie, "Popup.TimerDrain.Fill.Mask.gotoAndStop", 100 - timeLeft + 1)
    mTimer = timeLeft
  end
  return true
end
local function UpdateButtonState(movie, buttonIdx)
  local key = ""
  if mButtonStates[buttonIdx].key ~= "" then
    key = string.format("<%s>", mButtonStates[buttonIdx].key)
  end
  movie:SetLocalized(string.format("Popup.Button%i.Button.text", buttonIdx), key)
  movie:SetVariable(string.format("Popup.Button%i._visible", buttonIdx), false)
  movie:SetVariable(string.format("Popup.Locked%i._visible", buttonIdx), false)
  local alpha = 100
  if mButtonStates[buttonIdx].state == 0 then
    movie:SetVariable(string.format("Popup.Locked%i._visible", buttonIdx), true)
    alpha = 15
  else
    movie:SetVariable(string.format("Popup.Button%i._visible", buttonIdx), true)
  end
  movie:SetVariable(string.format("Popup.PowerIcon%i._alpha", buttonIdx), alpha)
  if buttonIdx == 1 then
    if mHasHealthTalent == 0 then
      movie:SetVariable("Popup.PowerIcon1.ExecutionHealth._visible", false)
      movie:SetVariable("Popup.PowerIcon1.ExecutionDefault._visible", true)
    else
      movie:SetVariable("Popup.PowerIcon1.ExecutionHealth._visible", true)
      movie:SetVariable("Popup.PowerIcon1.ExecutionDefault._visible", false)
    end
  end
end
function SetButtonState(movie, idx, state, key, desc, hasHealthTalent)
  local buttonIdx = tonumber(idx)
  local buttonState = mButtonStates[buttonIdx]
  mButtonStates[buttonIdx].state = tonumber(state)
  mButtonStates[buttonIdx].key = key
  mButtonStates[buttonIdx].desc = desc
  mHasHealthTalent = tonumber(hasHealthTalent)
  UpdateButtonState(movie, buttonIdx)
end
function Initialize(movie)
  for i = 1, 4 do
    mButtonStates[i] = {
      state = 0,
      key = "",
      desc = ""
    }
    UpdateButtonState(movie, i)
  end
  local movieInstance = gFlashMgr:FindMovie(movieHUD)
  if not IsNull(movieInstance) then
    movieInstance:Execute("NotifyExecutionsPopupVisible", "false")
  end
end
function Shutdown(movie)
  local movieInstance = gFlashMgr:FindMovie(movieHUD)
  if not IsNull(movieInstance) then
    movieInstance:Execute("NotifyExecutionsPopupVisible", "true")
  end
end
local DispatchInput = function(inputType)
  local players = gRegion:ScriptGetLocalPlayers()
  local avatar = players[1]:GetAvatar()
  if not IsNull(avatar) then
    local finisherAction = avatar:GetFinisherAction()
    if not IsNull(finisherAction) then
      finisherAction:SetSelectedFinisher(inputType - 1)
    end
  end
end
function onKeyDown_FINISHER_SELECT_1(movie)
  if mButtonStates[1].state == 1 then
    DispatchInput(1)
  end
  return true
end
function onKeyDown_FINISHER_SELECT_2(movie)
  if mButtonStates[2].state == 1 then
    DispatchInput(2)
  end
  return true
end
function onKeyDown_FINISHER_SELECT_3(movie)
  if mButtonStates[3].state == 1 then
    DispatchInput(3)
  end
  return true
end
function onKeyDown_FINISHER_SELECT_4(movie)
  if mButtonStates[4].state == 1 then
    DispatchInput(4)
  end
  return true
end
function onKeyUp_ACTION(movie)
  local players = gRegion:ScriptGetLocalPlayers()
  local avatar = players[1]:GetAvatar()
  if not IsNull(avatar) and not avatar:GetCarriedAvatarExecutionRequired() then
    local finisherAction = avatar:GetFinisherAction()
    if not IsNull(finisherAction) then
      finisherAction:CancelSelection()
    end
  end
  return true
end
function onKeyDown_ACTION(movie)
  return true
end
