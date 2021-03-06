local playerProfile, profileSettings, hostSettings, sessionSettings, focusedOptionsItem, scrollableItems
function Initialize(movie)
  playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  profileSettings = playerProfile:Settings()
  focusedOptionsItem = "DisplayOption"
  movie:SetFocus(focusedOptionsItem)
  movie:Stop()
end
local function SetContrast(percent)
  profileSettings:SetContrast(percent)
  return profileSettings:ContrastPercent()
end
local function SetBrightness(brightness)
  profileSettings:SetBrightness(brightness)
  return profileSettings:BrightnessPercent()
end
local function SetSubtitles(enabled)
  profileSettings:SetSubtitles(enabled)
  return profileSettings:Subtitles()
end
local function SetMusicGain(gainPercent)
  profileSettings:SetMusicGain(gainPercent)
  return profileSettings:MusicGainPercent()
end
local function SetFxGain(gainPercent)
  profileSettings:SetFxGain(gainPercent)
  return profileSettings:FxGainPercent()
end
local function SetVoiceGain(gainPercent)
  profileSettings:SetVoiceGain(gainPercent)
  return profileSettings:VoiceGainPercent()
end
local function SetAimSensitivity(sensitivityPercent)
  profileSettings:SetAimSensitivity(sensitivityPercent)
  return profileSettings:AimSensitivityPercent()
end
local function SetCameraInvert(inverted)
  profileSettings:SetCameraInverted(inverted)
  return profileSettings:CameraInverted()
end
local function SetForceFeedback(enabled)
  profileSettings:SetForceFeedback(enabled)
  return profileSettings:ForceFeedback()
end
local function SetPlayerCensored(censored)
  profileSettings:SetPlayerCensored(censored)
  return profileSettings:PlayerCensored()
end
local function SetTutorialEnabled(enabled)
  profileSettings:SetTutorialEnabled(enabled)
  return profileSettings:TutorialEnabled()
end
local function adjustBrightness(movie, up)
  local currentBrightness = profileSettings:BrightnessPercent()
  if up then
    currentBrightness = currentBrightness + 0.1
  else
    currentBrightness = currentBrightness - 0.1
  end
  currentBrightness = SetBrightness(currentBrightness)
  FlashMethod(movie, "setBrightness", currentBrightness * 100)
end
function flashAdjustBrightness(movie, up)
  if up == "false" then
    adjustBrightness(movie, false)
  else
    adjustBrightness(movie, true)
  end
end
local function adjustContrast(movie, up)
  local currentContrast = profileSettings:ContrastPercent()
  if up then
    currentContrast = currentContrast + 0.1
  else
    currentContrast = currentContrast - 0.1
  end
  currentContrast = SetContrast(currentContrast)
  FlashMethod(movie, "setContrast", currentContrast * 100)
end
function flashAdjustContrast(movie, up)
  if up == "false" then
    adjustContrast(movie, false)
  else
    adjustContrast(movie, true)
  end
end
local function adjustAimSensitivity(movie, up)
  local currentAimSensitivity = profileSettings:AimSensitivityPercent()
  if up then
    currentAimSensitivity = currentAimSensitivity + 0.1
  else
    currentAimSensitivity = currentAimSensitivity - 0.1
  end
  currentAimSensitivity = SetAimSensitivity(currentAimSensitivity)
  FlashMethod(movie, "setAimSensitivitySlider", currentAimSensitivity * 100)
end
function flashAdjustAimSensitivity(movie, up)
  if up == "false" then
    adjustAimSensitivity(movie, false)
  else
    adjustAimSensitivity(movie, true)
  end
end
local function adjustMusicGain(movie, up)
  local currentMusicGain = profileSettings:MusicGainPercent()
  if up then
    currentMusicGain = currentMusicGain + 0.1
  else
    currentMusicGain = currentMusicGain - 0.1
  end
  currentMusicGain = SetMusicGain(currentMusicGain)
  FlashMethod(movie, "setMusicVolume", currentMusicGain * 100)
end
function flashAdjustMusicGain(movie, up)
  if up == "false" then
    adjustMusicGain(movie, false)
  else
    adjustMusicGain(movie, true)
  end
end
local function adjustFxGain(movie, up)
  local currentFxGain = profileSettings:FxGainPercent()
  if up then
    currentFxGain = currentFxGain + 0.1
  else
    currentFxGain = currentFxGain - 0.1
  end
  currentFxGain = SetFxGain(currentFxGain)
  FlashMethod(movie, "setFxVolume", currentFxGain * 100)
end
function flashAdjustFxGain(movie, up)
  if up == "false" then
    adjustFxGain(movie, false)
  else
    adjustFxGain(movie, true)
  end
end
local function adjustVoiceGain(movie, up)
  local currentVoiceGain = profileSettings:VoiceGainPercent()
  if up then
    currentVoiceGain = currentVoiceGain + 0.1
  else
    currentVoiceGain = currentVoiceGain - 0.1
  end
  currentVoiceGain = SetVoiceGain(currentVoiceGain)
  FlashMethod(movie, "setVoiceVolume", currentVoiceGain * 100)
end
function flashAdjustVoiceGain(movie, up)
  if up == "false" then
    adjustVoiceGain(movie, false)
  else
    adjustVoiceGain(movie, true)
  end
end
local stickLayout = "default"
function adjustStickLayout(movie, up)
  if stickLayout == "default" then
    stickLayout = "lefty"
  else
    stickLayout = "default"
  end
  FlashMethod(movie, "setStickLayout", stickLayout)
end
local controllerLayout = {
  "Layout 1",
  "Layout 2",
  "Layout 3",
  "Layout 4"
}
local controllerIndex = 1
function adjustControllerLayout(movie, up)
  if up then
    controllerIndex = controllerIndex + 1
    if controllerIndex > #controllerLayout then
      controllerIndex = 1
    end
  else
    controllerIndex = controllerIndex - 1
    if controllerIndex < 1 then
      controllerIndex = #controllerLayout
    end
  end
  FlashMethod(movie, "setControllerLayout", controllerLayout[controllerIndex])
end
scrollableItems = {
  Frame2ButtonLabel0 = adjustBrightness,
  Frame2ButtonLabel1 = adjustContrast,
  Frame3ButtonLabel0 = adjustAimSensitivity,
  Frame3ButtonLabel4 = adjustControllerLayout,
  Frame3ButtonLabel5 = adjustStickLayout,
  Frame4ButtonLabel0 = adjustMusicGain,
  Frame4ButtonLabel1 = adjustFxGain,
  Frame4ButtonLabel2 = adjustVoiceGain
}
function onKeyDown_MENU_LEFT(movie)
  local name = "Frame" .. movie:GetVariable("_currentFrame") .. movie:GetFocus()
  if scrollableItems[name] then
    scrollableItems[name](movie, false)
    return true
  end
end
function onKeyDown_MENU_RIGHT(movie)
  local name = "Frame" .. movie:GetVariable("_currentFrame") .. movie:GetFocus()
  if scrollableItems[name] then
    scrollableItems[name](movie, true)
    return true
  end
end
local back = function(movie)
  local currentFrame = movie:GetVariable("_currentFrame")
  if currentFrame == "1" then
    movie:Close()
  else
    FlashMethod(movie, "goBack")
  end
end
function onKeyDown_MENU_CANCEL(movie)
  back(movie)
end
function BackButton_onPress(movie)
  back(movie)
end
function onKeyDown_MENU_SELECT(movie)
  if movie:GetVariable("_currentFrame") == "1" and movie:GetFocus() ~= "BackButton" then
    focusedOptionsItem = movie:GetFocus()
  end
end
function OptionsListButtonPressed(movie, buttonArg)
  focusedOptionsItem = buttonArg
  if buttonArg == "0" then
    FlashMethod(movie, "gotoAndStop", "Display")
  elseif buttonArg == "1" then
    FlashMethod(movie, "gotoAndStop", "Controls")
  elseif buttonArg == "2" then
    FlashMethod(movie, "gotoAndStop", "Audio")
  elseif buttonArg == "3" then
    FlashMethod(movie, "gotoAndStop", "Game")
  end
end
function LoadOptionsFrame(movie)
  FlashMethod(movie, "InitScreen_Options", "/EE_Menus/Options_Main_Title")
  FlashMethod(movie, "InitScreen_Options_Back", "/EE_Menus/Shared_Back")
  FlashMethod(movie, "OptionsList.ListClass.AddItem", "/EE_Menus/Options_Main_Display", false)
  FlashMethod(movie, "OptionsList.ListClass.AddItem", "/EE_Menus/Options_Main_Controls", false)
  FlashMethod(movie, "OptionsList.ListClass.AddItem", "/EE_Menus/Options_Main_Audio", false)
  FlashMethod(movie, "OptionsList.ListClass.AddItem", "/EE_Menus/Options_Main_Game", false)
  FlashMethod(movie, "OptionsList.ListClass.SetPressedCallback", "OptionsListButtonPressed")
  if focusedOptionsItem == nil then
    focusedOptionsItem = 0
  end
  FlashMethod(movie, "OptionsList.ListClass.SetSelected", focusedOptionsItem)
  FlashMethod(movie, "OptionsList.ListClass.SetupList")
end
function DisplayListButtonPressed(movie, buttonArg)
  if buttonArg == "2" then
    local currentSubtitles = profileSettings:Subtitles()
    currentSubtitles = SetSubtitles(not currentSubtitles)
    FlashMethod(movie, "setSubtitles", currentSubtitles)
  end
end
function LoadDisplayFrame(movie)
  FlashMethod(movie, "InitScreen_Display", "/EE_Menus/Options_Display_Title")
  FlashMethod(movie, "InitScreen_Display_Back", "/EE_Menus/Shared_Back")
  FlashMethod(movie, "InitScreen_Display_Select", "/EE_Menus/Shared_Select")
  FlashMethod(movie, "InitScreen_Display_Defaults", "/EE_Menus/Shared_Defaults")
  FlashMethod(movie, "DisplayList.ListClass.AddItem", "/EE_Menus/Options_Display_Brightness", false)
  FlashMethod(movie, "DisplayList.ListClass.AddItem", "/EE_Menus/Options_Display_Contrast", false)
  FlashMethod(movie, "DisplayList.ListClass.AddItem", "/EE_Menus/Options_Display_Subtitles", false)
  FlashMethod(movie, "DisplayList.ListClass.SetPressedCallback", "DisplayListButtonPressed")
  FlashMethod(movie, "DisplayList.ListClass.SetSelected", 0)
  FlashMethod(movie, "DisplayList.ListClass.SetupList")
  local currentBrightness = profileSettings:BrightnessPercent()
  local currentContrast = profileSettings:ContrastPercent()
  local currentSubtitles = profileSettings:Subtitles()
  FlashMethod(movie, "setBrightness", currentBrightness * 100)
  FlashMethod(movie, "setContrast", currentContrast * 100)
  FlashMethod(movie, "setSubtitles", currentSubtitles)
end
function ControlsListButtonPressed(movie, buttonArg)
  if buttonArg == "1" then
    local currentVibration = profileSettings:ForceFeedback()
    currentVibration = SetForceFeedback(not currentVibration)
    FlashMethod(movie, "setForceFeedback", currentVibration)
  elseif buttonArg == "2" then
    local currentCameraInverted = profileSettings:CameraInverted()
    currentCameraInverted = SetCameraInvert(not currentCameraInverted)
    FlashMethod(movie, "setCameraInverted", currentCameraInverted)
  end
end
function LoadControlsFrame(movie)
  FlashMethod(movie, "InitScreen_Controls", "/EE_Menus/Options_Controls_Title")
  FlashMethod(movie, "InitScreen_Controls_Back", "/EE_Menus/Shared_Back")
  FlashMethod(movie, "InitScreen_Controls_Select", "/EE_Menus/Shared_Select")
  FlashMethod(movie, "InitScreen_Controls_Defaults", "/EE_Menus/Shared_Defaults")
  FlashMethod(movie, "ControlList.ListClass.AddItem", "/EE_Menus/Options_Controls_Aim", false)
  FlashMethod(movie, "ControlList.ListClass.AddItem", "/EE_Menus/Options_Controls_Vibration", false)
  FlashMethod(movie, "ControlList.ListClass.AddItem", "/EE_Menus/Options_Controls_InvertY", false)
  local platform = movie:GetVariable("$platform")
  if platform ~= "WINDOWS" then
    FlashMethod(movie, "ControlList.ListClass.AddItem", "/EE_Menus/Options_Controls_ControllerLayout", false)
    FlashMethod(movie, "ControlList.ListClass.AddItem", "/EE_Menus/Options_Controls_StickLayout", false)
  end
  FlashMethod(movie, "ControlList.ListClass.SetPressedCallback", "ControlsListButtonPressed")
  FlashMethod(movie, "ControlList.ListClass.SetSelected", 0)
  FlashMethod(movie, "ControlList.ListClass.SetupList")
  local currentAimSensitivity = profileSettings:AimSensitivityPercent()
  local currentCameraInverted = profileSettings:CameraInverted()
  local currentForceFeedback = profileSettings:ForceFeedback()
  FlashMethod(movie, "setAimSensitivitySlider", currentAimSensitivity * 100)
  FlashMethod(movie, "setCameraInverted", currentCameraInverted)
  FlashMethod(movie, "setForceFeedback", currentForceFeedback)
  FlashMethod(movie, "setStickLayout", stickLayout)
  FlashMethod(movie, "setControllerLayout", controllerLayout[controllerIndex])
end
function LoadAudioFrame(movie)
  FlashMethod(movie, "InitScreen_Audio", "/EE_Menus/Options_Audio_Title")
  FlashMethod(movie, "InitScreen_Audio_Back", "/EE_Menus/Shared_Back")
  FlashMethod(movie, "InitScreen_Audio_Defaults", "/EE_Menus/Shared_Defaults")
  FlashMethod(movie, "AudioList.ListClass.AddItem", "/EE_Menus/Options_Audio_Music", false)
  FlashMethod(movie, "AudioList.ListClass.AddItem", "/EE_Menus/Options_Audio_Effects", false)
  FlashMethod(movie, "AudioList.ListClass.AddItem", "/EE_Menus/Options_Audio_Voice", false)
  FlashMethod(movie, "AudioList.ListClass.SetSelected", 0)
  FlashMethod(movie, "AudioList.ListClass.SetupList")
  local currentMusicGain = profileSettings:MusicGainPercent()
  local currentFxGain = profileSettings:FxGainPercent()
  local currentVoiceGain = profileSettings:VoiceGainPercent()
  FlashMethod(movie, "setMusicVolume", currentMusicGain * 100)
  FlashMethod(movie, "setFxVolume", currentFxGain * 100)
  FlashMethod(movie, "setVoiceVolume", currentVoiceGain * 100)
end
function GameListButtonPressed(movie, buttonArg)
  if buttonArg == "0" then
    local currentCensored = profileSettings:PlayerCensored()
    currentCensored = SetPlayerCensored(not currentCensored)
    FlashMethod(movie, "setGore", not currentCensored)
  elseif buttonArg == "1" then
    local currentHints = profileSettings:TutorialEnabled()
    currentHints = SetTutorialEnabled(not currentHints)
    FlashMethod(movie, "setTutorial", currentHints)
  end
end
function LoadGameFrame(movie)
  FlashMethod(movie, "InitScreen_Game", "/EE_Menus/Options_Game_Title")
  FlashMethod(movie, "InitScreen_Game_Select", "/EE_Menus/Shared_Select")
  FlashMethod(movie, "InitScreen_Game_Back", "/EE_Menus/Shared_Back")
  FlashMethod(movie, "InitScreen_Game_Defaults", "/EE_Menus/Shared_Defaults")
  FlashMethod(movie, "GameList.ListClass.AddItem", "/EE_Menus/Options_Game_Gore", false)
  FlashMethod(movie, "GameList.ListClass.AddItem", "/EE_Menus/Options_Game_Hints", false)
  FlashMethod(movie, "GameList.ListClass.SetPressedCallback", "GameListButtonPressed")
  FlashMethod(movie, "GameList.ListClass.SetSelected", 0)
  FlashMethod(movie, "GameList.ListClass.SetupList")
  local currentCensored = profileSettings:PlayerCensored()
  local currentHints = profileSettings:TutorialEnabled()
  FlashMethod(movie, "setGore", not currentCensored)
  FlashMethod(movie, "setTutorial", currentHints)
end
