local LIB = require("D2.Menus.SharedLibrary")
maxTime = 1
requiredButtonPressCount = 10
initialRateMultiplier = 0.5
rateIncreaseDelta = 0.03
rateDecreaseDelta = 0.1
failThreshold = 3
popupMode = String("")
local masterTimer = 0
local updateTimer = 0
local buttonPressCount = 0
local quickTimeMessage = "/D2/Language/Menu/QuickTimePopup_Message"
local jennyEndMessage = "/D2/Language/Menu/QuickTimePopupJenny_Message"
local leftMessage = "/D2/Language/Menu/QuickTimePopup_LeftMessage"
local rightMessage = "/D2/Language/Menu/QuickTimePopup_RightMessage"
local qteCinematic, failCinematic, finalCinematic, successCinematic
local masterRate = 1
local currentRate = 1
local gameRules
function SetMaxTime(movie, num)
  maxTime = tonumber(num)
end
function SetRequiredButtonPressCount(movie, num)
  requiredButtonPressCount = tonumber(num)
end
function SetInitialRateMultiplier(movie, num)
  initialRateMultiplier = tonumber(num)
end
function SetRateIncreaseDelta(movie, num)
  rateIncreaseDelta = tonumber(num)
end
function SetRateDecreaseDelta(movie, num)
  rateDecreaseDelta = tonumber(num)
end
function SetFailThreshold(movie, num)
  failThreshold = tonumber(num)
end
function SetPopupMode(movie, mode)
  popupMode = String(mode)
end
function SetMessage(movie, message)
  quickTimeMessage = String(message)
  FlashMethod(movie, "SetDescription", quickTimeMessage)
end
function Initialize(movie)
  gameRules = gRegion:GetGameRules()
  popupMode = _T.popupMode
  _T.qteSuccessState = false
  if popupMode == "QTE" then
    FlashMethod(movie, "SetDescription", quickTimeMessage)
    qteCinematic = gRegion:GetPlayingCinematic()
    masterRate = qteCinematic:GetPlayRate()
    currentRate = masterRate
    if masterRate * initialRateMultiplier > 0 then
      qteCinematic:SetPlayRate(masterRate * initialRateMultiplier)
    end
    failCinematic = _T.failCinematic
    successCinematic = _T.successCinematic
    finalCinematic = _T.finalCinematic
  elseif popupMode == "DECISION" then
    FlashMethod(movie, "SetDecisionOptions", leftMessage, rightMessage)
  elseif popupMode == "BUTTONPRESS" then
    FlashMethod(movie, "SetDescription", jennyEndMessage)
  end
end
local function OnSuccess(movie)
  qteCinematic:FirePort("StopPlaying")
  successCinematic:FirePort("StartPlaying")
  movie:Close()
end
local function OnFailure(movie)
  if _T.failCount == nil then
    _T.failCount = 0
  end
  _T.failCount = _T.failCount + 1
  if _T.failCount >= failThreshold then
    qteCinematic:FirePort("StopPlaying")
    finalCinematic:FirePort("StartPlaying")
    _T.failCount = 0
  else
    qteCinematic:FirePort("StopPlaying")
    failCinematic:FirePort("StartPlaying")
  end
  movie:Close()
end
function Update(movie)
  local delta = DeltaTime()
  masterTimer = masterTimer + delta
  updateTimer = updateTimer + delta
  if popupMode == "QTE" then
    if 1 <= updateTimer then
      currentRate = currentRate - rateDecreaseDelta
      if currentRate <= masterRate * initialRateMultiplier then
        currentRate = masterRate * initialRateMultiplier
      end
      qteCinematic:SetPlayRate(tonumber(currentRate))
      updateTimer = 0
    end
    if masterTimer > maxTime then
      OnFailure(movie)
    end
  elseif popupMode == "DECISION" then
    if masterTimer > maxTime then
      _T.decision = "NONE"
      movie:Close()
    end
  elseif popupMode == "BUTTONPRESS" and masterTimer > maxTime then
    movie:Close()
  end
end
local function handleButtonPress(movie)
  local levelInfo = gRegion:GetLevelInfo()
  local playerAvatar = gRegion:GetPlayerAvatar()
  local player = playerAvatar:GetPlayer()
  if popupMode == "QTE" then
    buttonPressCount = buttonPressCount + 1
    currentRate = currentRate + rateIncreaseDelta
    qteCinematic:SetPlayRate(tonumber(currentRate))
    player:PlayForceFeedback(0.5, 0.5, 0.1)
    if buttonPressCount >= requiredButtonPressCount then
      _T.qteSuccessState = true
      qteCinematic:SetPlayRate(masterRate)
      movie:Close()
    end
  elseif popupMode == "DECISION" then
    return true
  elseif popupMode == "BUTTONPRESS" then
    _T.qteSuccessState = true
    movie:Close()
  end
end
function onKeyDown_MENU_GENERIC1(movie)
  handleButtonPress(movie)
end
function onKeyDown_PICKUP(movie)
  handleButtonPress(movie)
end
function onKeyDown_USE(movie)
  handleButtonPress(movie)
end
function onKeyDown_LEAN_LEFT(movie)
  if popupMode == "QTE" then
    return true
  elseif popupMode == "DECISION" then
    _T.decision = "LEFT"
    gameRules:RequestUnpause()
    movie:Close()
  elseif popupMode == "BUTTONPRESS" then
    return true
  end
end
function onKeyDown_LEAN_RIGHT(movie)
  if popupMode == "QTE" then
    return true
  elseif popupMode == "DECISION" then
    _T.decision = "RIGHT"
    gameRules:RequestUnpause()
    movie:Close()
  elseif popupMode == "BUTTONPRESS" then
    return true
  end
end
