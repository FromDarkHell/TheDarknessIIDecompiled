local LIB = require("D2.Menus.SharedLibrary")
sndBack = Resource()
sndScroll = Resource()
sndSelect = Resource()
sndmusicVolume = Resource()
sndEffectVolume = Resource()
sndVOVolume = Resource()
sndMicVolume = Resource()
popupConfirmMovie = WeakResource()
pauseMovie = WeakResource()
music = Resource()
local SELECTION_Index = -1
local mCurSelection = -1
local mPlayerProfile, mProfileSettings, mHostSettings, mSessionSettings, mMusicInstance, mVOInstance, mMicInstance, mOldUsingEnglishVoiceOver
local itemMusic = "/D2/Language/Menu/Options_Audio_Music"
local itemEffects = "/D2/Language/Menu/Options_Audio_Effects"
local itemVoice = "/D2/Language/Menu/Options_Audio_Voice"
local itemVoiceOverEnglish = "/D2/Language/Menu/Options_Audio_VoiceOverEnglish"
local itemSteamVoiceVolume = "/D2/Language/Menu/Options_Audio_SteamVoiceVolume"
local itemAudioDeviceType = "/D2/Language/Menu/Options_Audio_DeviceType"
local itemList = {}
local statusSelect = "/D2/Language/Menu/Shared_Select"
local statusToggle = "/D2/Language/Menu/Shared_HToggle"
local statusDefault = "/D2/Language/Menu/Shared_Defaults"
local statusBack = "/D2/Language/Menu/Shared_Back"
local statusList = {
  statusSelect,
  statusToggle,
  statusDefault,
  statusBack
}
local popupItemOk = "/D2/Language/Menu/Confirm_Item_Ok"
local popupItemCancel = "/D2/Language/Menu/Confirm_Item_Cancel"
local mMovieInstance
transitionMovie = WeakResource()
local PlaySound = function(sound)
  return gRegion:PlaySound(sound, Vector(), false)
end
local function SetMusicGain(gainPercent)
  mProfileSettings:SetMusicGain(gainPercent)
  if gRegion:IsPlayingBackgroundMusic() == false and (IsNull(mMusicInstance) or mMusicInstance:IsPlaying() == false) then
    mMusicInstance = PlaySound(sndmusicVolume)
  end
  return mProfileSettings:MusicGainPercent()
end
local function SetFxGain(gainPercent)
  mProfileSettings:SetFxGain(gainPercent)
  PlaySound(sndEffectVolume)
  return mProfileSettings:FxGainPercent()
end
local function SetVoiceGain(gainPercent)
  mProfileSettings:SetVoiceGain(gainPercent)
  if IsNull(mVOInstance) or mVOInstance:IsPlaying() == false then
    mVOInstance = PlaySound(sndVOVolume)
  end
  return mProfileSettings:VoiceGainPercent()
end
local function SetMicrophoneRecieveGain(gainVol)
  mProfileSettings:SetMicrophoneRecieveGain(gainVol)
  Engine.GetVoiceMgr():SetPlaybackVolume(gainVol)
  PlaySound(sndMicVolume)
end
function MusicScrubberMoveCallback(movie, id)
  local v = movie:GetVariable("MusicScroll.ScrollClass.mPosition") / 100
  SetMusicGain(v)
end
function EffectsScrubberMoveCallback(movie, id)
  local v = movie:GetVariable("EffectsScroll.ScrollClass.mPosition") / 100
  SetFxGain(v)
end
function VoiceScrubberMoveCallback(movie, id)
  local v = movie:GetVariable("VoiceScroll.ScrollClass.mPosition") / 100
  SetVoiceGain(v)
end
local function ToggleVoiceOverEnglish(movie)
  mProfileSettings:SetUseEnglishVoiceOver(not mProfileSettings:UsingEnglishVoiceOver())
  PlaySound(sndSelect)
  FlashMethod(movie, "VoiceOverEnglish.CheckBoxClass.SetChecked", mProfileSettings:UsingEnglishVoiceOver())
end
function SteamVoiceScrubberMoveCallback(movie, id)
  local v = movie:GetVariable("SteamVoiceScroll.ScrollClass.mPosition") / 100
  SetMicrophoneRecieveGain(v)
end
function CheckBoxPressed(movie, cbName)
  ToggleVoiceOverEnglish(movie)
end
local function adjustAudioDevice(movie, up)
  if up then
    FlashMethod(movie, "DeviceTypeToggle.ToggleListClass.NextItem")
  else
    FlashMethod(movie, "DeviceTypeToggle.ToggleListClass.PreviousItem")
  end
  PlaySound(sndSelect)
end
function ToggleButtonPressed(movie, args)
  PlaySound(sndSelect)
end
function DeviceTypeTextLabelPressed(movie)
  adjustAudioDevice(movie, true)
end
local IsOffline = function()
  return Engine.GetMatchingService():GetState() == 0
end
function Initialize(movie)
  mMovieInstance = movie
  mPlayerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  mProfileSettings = mPlayerProfile:Settings()
  FlashMethod(movie, "MusicScroll.ScrollClass.SetRange", 100)
  FlashMethod(movie, "MusicScroll.ScrollClass.SetScrubberPos", mProfileSettings:MusicGainPercent() * 100)
  FlashMethod(movie, "MusicScroll.ScrollClass.SetButton0PressedCallback", "MusicScrubberMoveCallback")
  FlashMethod(movie, "MusicScroll.ScrollClass.SetButton1PressedCallback", "MusicScrubberMoveCallback")
  FlashMethod(movie, "MusicScroll.ScrollClass.SetScrubberPressedCallback", "MusicScrubberMoveCallback")
  FlashMethod(movie, "MusicScroll.ScrollClass.SetScrubberMoveCallback", "MusicScrubberMoveCallback")
  FlashMethod(movie, "EffectsScroll.ScrollClass.SetRange", 100)
  FlashMethod(movie, "EffectsScroll.ScrollClass.SetScrubberPos", mProfileSettings:FxGainPercent() * 100)
  FlashMethod(movie, "EffectsScroll.ScrollClass.SetButton0PressedCallback", "EffectsScrubberMoveCallback")
  FlashMethod(movie, "EffectsScroll.ScrollClass.SetButton1PressedCallback", "EffectsScrubberMoveCallback")
  FlashMethod(movie, "EffectsScroll.ScrollClass.SetScrubberReleasedCallback", "EffectsScrubberMoveCallback")
  FlashMethod(movie, "VoiceScroll.ScrollClass.SetRange", 100)
  FlashMethod(movie, "VoiceScroll.ScrollClass.SetScrubberPos", mProfileSettings:VoiceGainPercent() * 100)
  FlashMethod(movie, "VoiceScroll.ScrollClass.SetButton0PressedCallback", "VoiceScrubberMoveCallback")
  FlashMethod(movie, "VoiceScroll.ScrollClass.SetButton1PressedCallback", "VoiceScrubberMoveCallback")
  FlashMethod(movie, "VoiceScroll.ScrollClass.SetScrubberPressedCallback", "VoiceScrubberMoveCallback")
  FlashMethod(movie, "VoiceScroll.ScrollClass.SetScrubberMoveCallback", "VoiceScrubberMoveCallback")
  FlashMethod(movie, "VoiceOverEnglish.CheckBoxClass.SetChecked", mProfileSettings:UsingEnglishVoiceOver())
  movie:SetVariable("VoiceOverEnglish.CheckBoxClass.mSelectedColor", LIB.SELECTED_COLOR)
  FlashMethod(movie, "SteamVoiceScroll.ScrollClass.SetRange", 100)
  FlashMethod(movie, "SteamVoiceScroll.ScrollClass.SetScrubberPos", mProfileSettings:MicrophoneRecieveGainPercent() * 100)
  FlashMethod(movie, "SteamVoiceScroll.ScrollClass.SetButton0PressedCallback", "SteamVoiceScrubberMoveCallback")
  FlashMethod(movie, "SteamVoiceScroll.ScrollClass.SetButton1PressedCallback", "SteamVoiceScrubberMoveCallback")
  FlashMethod(movie, "SteamVoiceScroll.ScrollClass.SetScrubberReleasedCallback", "SteamVoiceScrubberMoveCallback")
  movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/Options_Audio_Title")
  movie:SetVariable("Title.TxtHolder.Txt.textAlign", "center")
  mCurSelection = SELECTION_Index
  mOldUsingEnglishVoiceOver = mProfileSettings:UsingEnglishVoiceOver()
  local itemVoiceOverEnglish = "/D2/Language/Menu/Options_Audio_VoiceOverEnglish"
  itemList = {
    itemMusic,
    itemEffects,
    itemVoice
  }
  local showEnglishVO = HasLocalizedVoiceOver() and IsOffline()
  if showEnglishVO then
    itemList[#itemList + 1] = itemVoiceOverEnglish
  end
  movie:SetVariable("VoiceOverEnglish._visible", showEnglishVO)
  FlashMethod(movie, "VoiceOverEnglish.CheckBoxClass.SetChecked", mProfileSettings:UsingEnglishVoiceOver())
  local isPC = LIB.IsPC(movie)
  if isPC then
    local ScrollOffsetY = movie:GetVariable("EffectsScroll._y") - movie:GetVariable("MusicScroll._y")
    if not showEnglishVO then
      local SteamVoiceScrollY = movie:GetVariable("SteamVoiceScroll._y") - ScrollOffsetY
      movie:SetVariable("SteamVoiceScroll._y", SteamVoiceScrollY)
      movie:SetVariable("DeviceTypeToggle._y", SteamVoiceScrollY)
    else
      local DeviceTypeToggleScrollY = movie:GetVariable("DeviceTypeToggle._y") - ScrollOffsetY
      movie:SetVariable("DeviceTypeToggle._y", DeviceTypeToggleScrollY)
    end
    itemList[#itemList + 1] = itemSteamVoiceVolume
    local toggleB0 = 0
    local toggleB1 = 345
    FlashMethod(movie, "DeviceTypeToggle.ToggleListClass.SetAlignment", "center")
    movie:SetVariable("DeviceTypeToggle.Button0._x", toggleB0)
    movie:SetVariable("DeviceTypeToggle.Button1._x", toggleB1)
    local ShiftX = 60
    local OptionsX = movie:GetVariable("OptionList._x")
    movie:SetVariable("OptionList._x", OptionsX - ShiftX)
    local xOffset = movie:GetVariable("DeviceTypeToggle._x") - 45
    movie:SetVariable("MusicScroll._x", xOffset)
    movie:SetVariable("EffectsScroll._x", xOffset)
    movie:SetVariable("VoiceScroll._x", xOffset)
    movie:SetVariable("SteamVoiceScroll._x", xOffset)
    movie:SetVariable("DeviceTypeToggle._x", xOffset - 25)
    local ScrollSize = toggleB1 - toggleB0 + 35
    movie:SetVariable("VoiceOverEnglish._x", xOffset + (toggleB1 - toggleB0 + 80) / 2)
    FlashMethod(movie, "MusicScroll.ScrollClass.SetSize", ScrollSize)
    FlashMethod(movie, "EffectsScroll.ScrollClass.SetSize", ScrollSize)
    FlashMethod(movie, "VoiceScroll.ScrollClass.SetSize", ScrollSize)
    FlashMethod(movie, "SteamVoiceScroll.ScrollClass.SetSize", ScrollSize)
    FlashMethod(movie, "DeviceTypeToggle.ToggleListClass.SetTextLabelCallbackOnPress", "DeviceTypeTextLabelPressed")
    FlashMethod(movie, "DeviceTypeToggle.ToggleListClass.SetButton0PressedCallback", "ToggleButtonPressed")
    FlashMethod(movie, "DeviceTypeToggle.ToggleListClass.SetButton1PressedCallback", "ToggleButtonPressed")
    FlashMethod(movie, "DeviceTypeToggle.OptionList.ListClass.SetSelectedCallback", "ToggleListButtonSelected")
    FlashMethod(movie, "DeviceTypeToggle.ListClass.SetAlignment", "left")
    FlashMethod(movie, "DeviceTypeToggle.ListClass.SetPressedCallback", "SoundDeviceListPressed")
    movie:SetVariable("DeviceTypeToggle.OptionList._x", xOffset)
    movie:SetVariable("DeviceTypeToggle.OptionListBackground._x", ScrollSize)
    movie:SetVariable("DeviceTypeToggle.Button1._x", ScrollSize + 96)
    movie:SetVariable("DeviceTypeToggle.TextLabel._x", ScrollSize - toggleB1)
    local SoundDeviceNameLen = 30
    local soundSys = gClient:GetSoundSys()
    if soundSys ~= nil then
      local soundDevices = soundSys:GetDeviceNames()
      if not IsNull(soundDevices) then
        for i = 1, #soundDevices do
          if SoundDeviceNameLen >= string.len(soundDevices[i]) then
            FlashMethod(movie, "DeviceTypeToggle.ToggleListClass.AddItem", soundDevices[i])
          else
            FlashMethod(movie, "DeviceTypeToggle.ToggleListClass.AddItem", string.sub(soundDevices[i], 0, SoundDeviceNameLen) .. "...")
          end
        end
        local deviceId = soundSys:GetDeviceId()
        if 0 <= deviceId then
          FlashMethod(movie, "DeviceTypeToggle.ToggleListClass.SetSelected", deviceId)
        end
      end
    end
    itemList[#itemList + 1] = itemAudioDeviceType
  end
  movie:SetVariable("DeviceTypeToggle._visible", isPC)
  movie:SetVariable("SteamVoiceScroll._visible", isPC)
  for i = 1, #statusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusList[i], statusList[i] ~= statusToggle)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusSelect, false)
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
  for i = 1, #itemList do
    FlashMethod(movie, "OptionList.ListClass.AddItem", itemList[i], false)
  end
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "right")
  FlashMethod(movie, "OptionList.ListClass.SetSelectedCallback", "ListButtonSelected")
  FlashMethod(movie, "OptionList.ListClass.SetUnselectedCallback", "ListButtonUnselected")
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
end
function Shutdown(movie)
  if not IsNull(mMusicInstance) then
    mMusicInstance:Stop(true)
  end
  mMusicInstance = nil
end
function ChangeVoiceOverEnglish(movie, args)
  if tonumber(args) == 0 then
    PlaySound(sndSelect)
    movie:RestartCheckpointVoiceOver()
  elseif tonumber(args) == 1 then
    ToggleVoiceOverEnglish(movie)
  end
end
local function Back(movie)
  PlaySound(sndBack)
  if LIB.IsPC(movie) then
    local soundSys = gClient:GetSoundSys()
    if soundSys ~= nil then
      local curAudioDeviceSelection = tonumber(movie:GetVariable("DeviceTypeToggle.ToggleListClass.mCurSelection"))
      if curAudioDeviceSelection ~= soundSys:GetDeviceId() and 0 <= curAudioDeviceSelection then
        soundSys:SetDeviceId(curAudioDeviceSelection)
      end
    end
  end
  if gFlashMgr:FindMovie(pauseMovie) and not mOldUsingEnglishVoiceOver == mProfileSettings:UsingEnglishVoiceOver() then
    local popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/Options_Audio_VoiceOverEnglishConfirm", popupItemOk, popupItemCancel, "ChangeVoiceOverEnglish")
    return
  end
  if not IsNull(mVOInstance) then
    mVOInstance:Stop(true)
  end
  mMovieInstance:Close()
end
local function SetDefaults(movie)
  mProfileSettings:SetAudioDefaults()
  FlashMethod(movie, "MusicScroll.ScrollClass.SetScrubberPos", mProfileSettings:MusicGainPercent() * 100)
  FlashMethod(movie, "EffectsScroll.ScrollClass.SetScrubberPos", mProfileSettings:FxGainPercent() * 100)
  FlashMethod(movie, "VoiceScroll.ScrollClass.SetScrubberPos", mProfileSettings:VoiceGainPercent() * 100)
  FlashMethod(movie, "VoiceOverEnglish.CheckBoxClass.SetChecked", mProfileSettings:UsingEnglishVoiceOver())
  FlashMethod(movie, "SteamVoiceScroll.ScrollClass.SetScrubberPos", mProfileSettings:MicrophoneRecieveGainPercent() * 100)
  PlaySound(sndSelect)
end
function onKeyDown_MENU_CANCEL(movie)
  Back(movie)
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if statusList[index] == statusDefault then
    SetDefaults(movie)
  elseif statusList[index] == statusBack then
    Back(movie)
  end
end
function onKeyDown_MENU_GENERIC1(movie)
  SetDefaults(movie)
end
local function adjustMusicGain(movie, up)
  local currentMusicGain = mProfileSettings:MusicGainPercent()
  if up then
    currentMusicGain = currentMusicGain + 0.1
  else
    currentMusicGain = currentMusicGain - 0.1
  end
  currentMusicGain = SetMusicGain(currentMusicGain)
  FlashMethod(movie, "MusicScroll.ScrollClass.SetScrubberPos", currentMusicGain * 100)
end
function flashAdjustMusicGain(movie, up)
  if up == "false" then
    adjustMusicGain(movie, false)
  else
    adjustMusicGain(movie, true)
  end
end
local function adjustFxGain(movie, up)
  local currentFxGain = mProfileSettings:FxGainPercent()
  if up then
    currentFxGain = currentFxGain + 0.1
  else
    currentFxGain = currentFxGain - 0.1
  end
  currentFxGain = SetFxGain(currentFxGain)
  FlashMethod(movie, "EffectsScroll.ScrollClass.SetScrubberPos", currentFxGain * 100)
end
function flashAdjustFxGain(movie, up)
  if up == "false" then
    adjustFxGain(movie, false)
  else
    adjustFxGain(movie, true)
  end
end
local function adjustVoiceGain(movie, up)
  local currentVoiceGain = mProfileSettings:VoiceGainPercent()
  if up then
    currentVoiceGain = currentVoiceGain + 0.1
  else
    currentVoiceGain = currentVoiceGain - 0.1
  end
  currentVoiceGain = SetVoiceGain(currentVoiceGain)
  FlashMethod(movie, "VoiceScroll.ScrollClass.SetScrubberPos", currentVoiceGain * 100)
end
function flashAdjustVoiceGain(movie, up)
  if up == "false" then
    adjustVoiceGain(movie, false)
  else
    adjustVoiceGain(movie, true)
  end
end
local function adjustMicReceiveGain(movie, up)
  local currentMicReceiveGain = mProfileSettings:MicrophoneRecieveGainPercent()
  if up then
    currentMicReceiveGain = currentMicReceiveGain + 0.1
  else
    currentMicReceiveGain = currentMicReceiveGain - 0.1
  end
  SetMicrophoneRecieveGain(currentMicReceiveGain)
  FlashMethod(movie, "SteamVoiceScroll.ScrollClass.SetScrubberPos", currentMicReceiveGain * 100)
end
function flashAdjustMicReceiveGain(movie, up)
  if up == "false" then
    adjustMicReceiveGain(movie, false)
  else
    adjustMicReceiveGain(movie, true)
  end
end
local function Adjust(movie, up)
  if mCurSelection == SELECTION_Index then
    return
  end
  if itemList[mCurSelection] == itemMusic then
    adjustMusicGain(movie, up)
  elseif itemList[mCurSelection] == itemEffects then
    adjustFxGain(movie, up)
  elseif itemList[mCurSelection] == itemVoice then
    adjustVoiceGain(movie, up)
  elseif itemList[mCurSelection] == itemAudioDeviceType then
    adjustAudioDevice(movie, up)
  elseif itemList[mCurSelection] == itemSteamVoiceVolume then
    adjustMicReceiveGain(movie, up)
  end
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  Adjust(movie, false)
  return true
end
function onKeyDown_MENU_LEFT(movie)
  Adjust(movie, false)
  return true
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  Adjust(movie, true)
  return true
end
function onKeyDown_MENU_RIGHT(movie)
  Adjust(movie, true)
  return true
end
function onKeyDown_MENU_UP_FROM_ANALOG(movie)
  return LIB.ListClassVerticalScroll(movie, "OptionList", -1)
end
function onKeyDown_MENU_UP(movie)
  return LIB.ListClassVerticalScroll(movie, "OptionList", -1)
end
function onKeyDown_MENU_DOWN_FROM_ANALOG(movie)
  return LIB.ListClassVerticalScroll(movie, "OptionList", 1)
end
function onKeyDown_MENU_DOWN(movie)
  return LIB.ListClassVerticalScroll(movie, "OptionList", 1)
end
local function HighlightControl(movie, index, on)
  local clip
  if itemList[index] == itemMusic then
    clip = "MusicScroll"
  elseif itemList[index] == itemEffects then
    clip = "EffectsScroll"
  elseif itemList[index] == itemVoice then
    clip = "VoiceScroll"
  elseif itemList[index] == itemVoiceOverEnglish then
    clip = "VoiceOverEnglish"
  elseif itemList[index] == itemSteamVoiceVolume then
    clip = "SteamVoiceScroll"
  elseif itemList[index] == itemAudioDeviceType then
    clip = "DeviceTypeToggle"
  end
  if not IsNull(clip) then
    local newColor = 16777215
    if on then
      newColor = LIB.SELECTED_COLOR
    end
    movie:SetVariable(clip .. "._color", newColor)
  end
end
function ListButtonUnselected(movie, buttonArg)
  local btn = tonumber(buttonArg) + 1
  HighlightControl(movie, btn, false)
end
function ListButtonSelected(movie, buttonArg)
  if 0 < mCurSelection then
    PlaySound(sndScroll)
  end
  mCurSelection = tonumber(buttonArg) + 1
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusSelect, itemList[mCurSelection] == itemVoiceOverEnglish)
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusToggle, itemList[mCurSelection] ~= itemVoiceOverEnglish)
  HighlightControl(movie, mCurSelection, true)
end
function ListButtonPressed(movie, buttonArg)
  local idx = tonumber(buttonArg) + 1
  if itemList[idx] == itemVoiceOverEnglish then
    ToggleVoiceOverEnglish(movie)
  elseif itemList[idx] == itemAudioDeviceType then
    adjustAudioDevice(movie, true)
  end
end
